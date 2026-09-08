import subprocess
import re
from collections import defaultdict
 
 
def get_changed_line_numbers(base, target, file_path):
    diff = subprocess.run(
        ['git', 'diff', '-U0', base, target, '--', file_path],
        capture_output=True, text=True, check=True
    ).stdout
 
    line_numbers = []
    for line in diff.split('\n'):
        if line.startswith('@@'):
            match = re.search(r'\+(\d+)(?:,(\d+))?', line)
            if match:
                start = int(match.group(1))
                count = int(match.group(2)) if match.group(2) else 1
                line_numbers.extend(range(start, start + count))
 
    return line_numbers
 
 
def get_blame_for_file(target_branch, file_path):
    """
    Возвращает словарь {номер_строки: хеш_коммита} для всего файла.
    Используем --line-porcelain для надёжного парсинга.
    """
    try:
        output = subprocess.run(
            ['git', 'blame', '--line-porcelain', target_branch, '--', file_path],
            capture_output=True, text=True, check=True
        ).stdout
    except subprocess.CalledProcessError:
        # Файл мог быть удалён или переименован
        return {}
 
    blame_map = {}
    lines = output.split('\n')
    i = 0
 
    while i < len(lines):
        line = lines[i]
 
        if line and not line.startswith('\t') and not line.startswith(' '):
            parts = line.split()
            if len(parts) >= 3:
                commit_hash = parts[0]
                final_line_num = int(parts[2])
 
                i += 1
                while i < len(lines) and not lines[i].startswith('\t'):
                    i += 1
 
                if i < len(lines) and lines[i].startswith('\t'):
                    blame_map[final_line_num] = commit_hash
 
        i += 1
 
    return blame_map
 
 
def get_file_content_lines(revision, file_path):
    """Содержимое файла на указанной ревизии, построчно (индекс 0 = строка 1)."""
    output = subprocess.run(
        ['git', 'show', f'{revision}:{file_path}'],
        capture_output=True, text=True, check=True
    ).stdout
    return output.split('\n')
 
 
def find_duplicate_blocks(lines, min_block_size=3):
    """
    Находит блоки из min_block_size подряд идущих строк, встречающиеся
    в файле более одного раза (n-граммы по нормализованному содержимому).
 
    Возвращает dict: номер_строки (1-based) -> set(номера строк-"дублей"
    в других местах файла, входящих в такой же блок).
    """
    normalized = [l.strip() for l in lines]
    n = len(normalized)
 
    block_positions = defaultdict(list)  # содержимое блока -> список стартовых индексов (0-based)
    for i in range(n - min_block_size + 1):
        block = tuple(normalized[i:i + min_block_size])
        if all(b == '' for b in block):
            continue  # пропускаем пустые блоки (частая ложная дубликация)
        block_positions[block].append(i)
 
    duplicate_lines = defaultdict(set)
    for block, positions in block_positions.items():
        if len(positions) < 2:
            continue
        for pi, start_i in enumerate(positions):
            for pj, start_j in enumerate(positions):
                if pi == pj:
                    continue
                for offset in range(min_block_size):
                    duplicate_lines[start_i + offset + 1].add(start_j + offset + 1)
 
    return duplicate_lines
 
 
def build_force_skip_map(force_skip):
    """
    Превращает список принудительных исключений в удобный для поиска словарь.
 
    force_skip — список элементов вида:
        (file_path, line_number)              — одна строка
        (file_path, (start_line, end_line))    — диапазон строк, включительно
 
    Пример:
        FORCE_SKIP = [
            ('path/to/file.py', 42),
            ('path/to/file.py', (100, 115)),
            ('other/file.py', 7),
        ]
 
    Возвращает dict: file_path -> set(номера строк).
    """
    skip_map = defaultdict(set)
    for file_path, line_spec in force_skip:
        if isinstance(line_spec, tuple):
            start, end = line_spec
            skip_map[file_path].update(range(start, end + 1))
        else:
            skip_map[file_path].add(line_spec)
    return skip_map
 
 
def filter_out_copied_lines(changed_lines, duplicate_lines_map):
    """
    Исключает из changed_lines номера строк, которые являются частью
    блока, дублирующего уже существующий (неизменённый) кусок файла.
 
    Логика: если у строки есть "дубль" в другом месте файла, который
    НЕ входит в список изменённых строк — значит, этот блок уже
    существовал раньше, а текущая строка, скорее всего, просто копия.
    Blame для неё ненадёжен, исключаем.
    """
    changed_set = set(changed_lines)
    filtered = []
    excluded = []
 
    for line_num in changed_lines:
        dups = duplicate_lines_map.get(line_num, set())
        has_unchanged_original = any(d not in changed_set for d in dups)
        if has_unchanged_original:
            excluded.append(line_num)
        else:
            filtered.append(line_num)
 
    return filtered, excluded
 
 
def analyze_file(base, target, file_path, min_block_size=3, force_skip_map=None):
    """
    force_skip_map — результат build_force_skip_map(). Строки из него
    исключаются из анализа ещё до поиска дублей (принудительно, вручную).
    """
    force_skip_lines = (force_skip_map or {}).get(file_path, set())
 
    changed = get_changed_line_numbers(base, target, file_path)
    changed = [ln for ln in changed if ln not in force_skip_lines]
 
    file_lines = get_file_content_lines(target, file_path)
    dup_map = find_duplicate_blocks(file_lines, min_block_size=min_block_size)
 
    clean_changed, excluded_as_copies = filter_out_copied_lines(changed, dup_map)
 
    blame_map = get_blame_for_file(target, file_path)
 
    result = {ln: blame_map.get(ln) for ln in clean_changed}
 
    return {
        'blame_by_line': result,
        'excluded_as_copies': excluded_as_copies,        # найдено автоматически, как копипаст
        'excluded_forced': sorted(force_skip_lines),      # исключено вручную через FORCE_SKIP
    }
 
 
if __name__ == '__main__':
    import json
 
    # Задаём здесь принудительные исключения на старте.
    FORCE_SKIP = [
        # ('path/to/file.py', 42),
        # ('path/to/file.py', (100, 115)),
    ]
    force_skip_map = build_force_skip_map(FORCE_SKIP)
 
    res = analyze_file('main', 'HEAD', 'path/to/file.py', force_skip_map=force_skip_map)
    print(json.dumps(res, indent=2, ensure_ascii=False))