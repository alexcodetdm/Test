В PowerShell есть несколько способов чтения JSON файлов. Вот основные методы:

1. Использование Get-Content и ConvertFrom-Json
powershell
# Чтение JSON файла
$jsonContent = Get-Content -Path "C:\путь\к\файлу.json" -Raw
$data = $jsonContent | ConvertFrom-Json

# Теперь можно работать с данными
$data.PropertyName
2. Более компактная запись
powershell
$data = Get-Content "C:\путь\к\файлу.json" -Raw | ConvertFrom-Json
3. Пример с реальным JSON файлом
Предположим, у нас есть файл config.json:

json
{
    "database": {
        "server": "localhost",
        "name": "mydb",
        "port": 5432
    },
    "settings": {
        "timeout": 30,
        "retries": 3
    }
}
Чтение и использование:

powershell
$config = Get-Content "config.json" -Raw | ConvertFrom-Json

# Доступ к свойствам
$server = $config.database.server
$timeout = $config.settings.timeout

Write-Host "Сервер: $server"
Write-Host "Таймаут: $timeout секунд"
4. Обработка ошибок
powershell
try {
    $data = Get-Content "config.json" -Raw | ConvertFrom-Json
    Write-Host "JSON успешно прочитан"
}
catch {
    Write-Error "Ошибка при чтении JSON: $_"
}
5. Чтение JSON из строки
powershell
$jsonString = '{"name": "John", "age": 30, "cities": ["Moscow", "SPb"]}'
$data = $jsonString | ConvertFrom-Json

$data.name    # John
$data.age     # 30
$data.cities  # Moscow, SPb
6. Для массивов JSON
Если JSON содержит массив:

json
[
    {"name": "John", "age": 30},
    {"name": "Alice", "age": 25}
]
powershell
$users = Get-Content "users.json" -Raw | ConvertFrom-Json

foreach ($user in $users) {
    Write-Host "Имя: $($user.name), Возраст: $($user.age)"
}
Важные моменты:
-Raw параметр в Get-Content читает файл как одну строку, что важно для корректного парсинга JSON

ConvertFrom-Json создает объекты PSCustomObject

Для работы с вложенными свойствами используйте точечную нотацию

JSON чувствителен к регистру символов

Это основные способы работы с JSON в PowerShell!