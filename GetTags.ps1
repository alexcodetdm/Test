Да, у Bitbucket есть REST API, который позволяет получить содержимое файла из конкретной ветки, включая мастер.

Основной метод API
text
GET /2.0/repositories/{workspace}/{repo_slug}/src/{branch}/{file_path}
Пример запроса
bash
curl -X GET \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/src/master/path/to/file.txt"
Параметры
{workspace} - имя рабочего пространства или пользователя

{repo_slug} - идентификатор репозитория

{branch} - имя ветки (например, master, main)

{file_path} - путь к файлу относительно корня репозитория

Аутентификация
Вы можете использовать:

Личный access token

OAuth

Basic auth (username:password)

Пример на Python
python
import requests

def get_file_content(workspace, repo_slug, branch, file_path, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/src/{branch}/{file_path}"
    headers = {
        "Authorization": f"Bearer {token}"
    }
    
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        return response.text
    else:
        raise Exception(f"Error: {response.status_code} - {response.text}")

# Использование
content = get_file_content(
    "your-workspace",
    "your-repo",
    "master", 
    "README.md",
    "your-access-token"
)
print(content)
Альтернативный метод
Также можно использовать метод для получения конкретного файла по хешу коммита:

text
GET /2.0/repositories/{workspace}/{repo_slug}/raw/{file_path}?at={branch}
Этот метод возвращает сырое содержимое файла без дополнительной информации.

выводит только 1500 строк а в файле больше
Да, у Bitbucket API есть ограничение на количество возвращаемых строк. Это известное ограничение. Вот несколько способов обойти его:

1. Использование параметра pagination
Bitbucket API использует пагинацию. Проверьте заголовки ответа или тело ответа на наличие ссылок на следующую страницу:

python
import requests

def get_large_file_content(workspace, repo_slug, branch, file_path, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/src/{branch}/{file_path}"
    headers = {"Authorization": f"Bearer {token}"}
    
    all_content = []
    while url:
        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            raise Exception(f"Error: {response.status_code} - {response.text}")
        
        # Добавляем содержимое текущей страницы
        all_content.append(response.text)
        
        # Проверяем наличие следующей страницы
        if 'next' in response.links:
            url = response.links['next']['url']
        else:
            url = None
    
    return ''.join(all_content)
2. Использование raw endpoint (рекомендуется)
Для больших файлов лучше использовать raw endpoint, который не имеет ограничений на размер:

python
import requests

def get_file_content_raw(workspace, repo_slug, branch, file_path, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/src/{branch}/{file_path}"
    
    # Добавляем параметр для raw content
    params = {'format': 'meta'}  # или используйте raw endpoint ниже
    
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(url, headers=headers, params=params)
    return response.text
3. Альтернативный raw endpoint
python
def get_file_direct_raw(workspace, repo_slug, branch, file_path, token):
    # Этот endpoint возвращает чистое содержимое файла
    url = f"https://bitbucket.org/{workspace}/{repo_slug}/raw/{branch}/{file_path}"
    
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(url, headers=headers)
    return response.text
4. Использование Git команды (если возможно)
Если у вас есть доступ к репозиторию через Git:

bash
git clone https://x-token-auth:{token}@bitbucket.org/{workspace}/{repo_slug}.git
cd {repo_slug}
git checkout {branch}
cat {file_path}
5. Проверка размера файла перед загрузкой
python
def get_file_with_size_check(workspace, repo_slug, branch, file_path, token):
    # Сначала получаем информацию о файле
    info_url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/src/{branch}/{file_path}?format=meta"
    headers = {"Authorization": f"Bearer {token}"}
    
    info_response = requests.get(info_url, headers=headers)
    file_info = info_response.json()
    
    print(f"Размер файла: {file_info.get('size', 'Unknown')} bytes")
    
    # Затем загружаем содержимое
    return get_file_direct_raw(workspace, repo_slug, branch, file_path, token)
Рекомендую использовать метод №3 с raw endpoint - он наиболее надежен для больших файлов и не имеет ограничений на количество строк.

есть ли API для получения кодов tags из bitbucket ?
Да, у Bitbucket есть несколько API для работы с тегами (tags). Вот основные методы:

1. Получение списка всех тегов
text
GET /2.0/repositories/{workspace}/{repo_slug}/refs/tags
Пример:

python
import requests

def get_tags(workspace, repo_slug, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/refs/tags"
    headers = {"Authorization": f"Bearer {token}"}
    
    tags = []
    while url:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            data = response.json()
            tags.extend(data['values'])
            url = data.get('next')
        else:
            raise Exception(f"Error: {response.status_code}")
    
    return tags

# Использование
tags = get_tags("your-workspace", "your-repo", "your-token")
for tag in tags:
    print(f"Tag: {tag['name']}, Commit: {tag['target']['hash']}")
2. Получение информации о конкретном теге
text
GET /2.0/repositories/{workspace}/{repo_slug}/refs/tags/{tag_name}
Пример:

python
def get_tag_info(workspace, repo_slug, tag_name, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/refs/tags/{tag_name}"
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Error: {response.status_code}")

tag_info = get_tag_info("workspace", "repo", "v1.0.0", "token")
3. Получение содержимого файла из конкретного тега
text
GET /2.0/repositories/{workspace}/{repo_slug}/src/{tag_name}/{file_path}
Пример:

python
def get_file_from_tag(workspace, repo_slug, tag_name, file_path, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/src/{tag_name}/{file_path}"
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.text
    else:
        raise Exception(f"Error: {response.status_code}")

# Получить README.md из тега v1.0.0
content = get_file_from_tag("workspace", "repo", "v1.0.0", "README.md", "token")
4. Raw содержимое файла из тега
text
GET /2.0/repositories/{workspace}/{repo_slug}/raw/{file_path}?at=refs%2Ftags%2F{tag_name}
Пример:

python
def get_raw_file_from_tag(workspace, repo_slug, tag_name, file_path, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/raw/{file_path}"
    params = {'at': f'refs/tags/{tag_name}'}
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        return response.text
    else:
        raise Exception(f"Error: {response.status_code}")

content = get_raw_file_from_tag("workspace", "repo", "v1.0.0", "package.json", "token")
5. Создание нового тега
text
POST /2.0/repositories/{workspace}/{repo_slug}/refs/tags
Пример:

python
def create_tag(workspace, repo_slug, tag_name, commit_hash, token):
    url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}/refs/tags"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    data = {
        "name": tag_name,
        "target": {
            "hash": commit_hash
        }
    }
    
    response = requests.post(url, headers=headers, json=data)
    return response.status_code == 201
6. Полный пример работы с тегами
python
import requests

class BitbucketTags:
    def __init__(self, workspace, repo_slug, token):
        self.workspace = workspace
        self.repo_slug = repo_slug
        self.token = token
        self.base_url = f"https://api.bitbucket.org/2.0/repositories/{workspace}/{repo_slug}"
    
    def get_all_tags(self):
        """Получить все теги репозитория"""
        url = f"{self.base_url}/refs/tags"
        headers = {"Authorization": f"Bearer {self.token}"}
        
        tags = []
        while url:
            response = requests.get(url, headers=headers)
            if response.status_code == 200:
                data = response.json()
                tags.extend(data['values'])
                url = data.get('next')
            else:
                raise Exception(f"Error: {response.status_code}")
        
        return tags
    
    def get_file_from_tag(self, tag_name, file_path):
        """Получить содержимое файла из конкретного тега"""
        url = f"{self.base_url}/src/{tag_name}/{file_path}"
        headers = {"Authorization": f"Bearer {self.token}"}
        
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            return response.text
        else:
            raise Exception(f"Error: {response.status_code}")
    
    def get_latest_tag(self):
        """Получить последний тег (по дате создания)"""
        tags = self.get_all_tags()
        if tags:
            # Сортируем по дате создания
            sorted_tags = sorted(tags, key=lambda x: x['date'], reverse=True)
            return sorted_tags[0]
        return None

# Использование
bb_tags = BitbucketTags("your-workspace", "your-repo", "your-token")

# Получить все теги
all_tags = bb_tags.get_all_tags()
for tag in all_tags:
    print(f"Tag: {tag['name']}")

# Получить файл из конкретного тега
content = bb_tags.get_file_from_tag("v1.0.0", "src/main.py")
Эти API позволяют полностью управлять тегами в Bitbucket и получать код из конкретных версий проекта.

приведи пример для получения tags из PowerShell
Вот примеры получения тегов из Bitbucket с использованием PowerShell:

1. Базовый пример - получение списка тегов
powershell
# Получение списка всех тегов
function Get-BitbucketTags {
    param(
        [string]$Workspace,
        [string]$RepoSlug,
        [string]$Token
    )
    
    $url = "https://api.bitbucket.org/2.0/repositories/$Workspace/$RepoSlug/refs/tags"
    $headers = @{
        "Authorization" = "Bearer $Token"
    }
    
    $allTags = @()
    
    do {
        Write-Host "Fetching: $url"
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        
        $allTags += $response.values
        
        # Проверяем наличие следующей страницы
        if ($response.next) {
            $url = $response.next
        } else {
            $url = $null
        }
    } while ($url)
    
    return $allTags
}

# Использование
$tags = Get-BitbucketTags -Workspace "your-workspace" -RepoSlug "your-repo" -Token "your-token"

# Вывод результатов
$tags | ForEach-Object {
    Write-Host "Tag: $($_.name)" -ForegroundColor Green
    Write-Host "  Commit: $($_.target.hash)" -ForegroundColor Yellow
    Write-Host "  Date: $($_.date)" -ForegroundColor Cyan
    Write-Host "---"
}
2. Получение информации о конкретном теге
powershell
function Get-BitbucketTag {
    param(
        [string]$Workspace,
        [string]$RepoSlug,
        [string]$TagName,
        [string]$Token
    )
    
    $url = "https://api.bitbucket.org/2.0/repositories/$Workspace/$RepoSlug/refs/tags/$TagName"
    $headers = @{
        "Authorization" = "Bearer $Token"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        return $response
    }
    catch {
        Write-Error "Error getting tag: $($_.Exception.Message)"
        return $null
    }
}

# Использование
$tagInfo = Get-BitbucketTag -Workspace "your-workspace" -RepoSlug "your-repo" -TagName "v1.0.0" -Token "your-token"
if ($tagInfo) {
    Write-Host "Tag Info:" -ForegroundColor Green
    $tagInfo | ConvertTo-Json -Depth 3
}
3. Получение файла из конкретного тега
powershell
function Get-FileFromTag {
    param(
        [string]$Workspace,
        [string]$RepoSlug,
        [string]$TagName,
        [string]$FilePath,
        [string]$Token
    )
    
    $url = "https://api.bitbucket.org/2.0/repositories/$Workspace/$RepoSlug/src/$TagName/$FilePath"
    $headers = @{
        "Authorization" = "Bearer $Token"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        return $response
    }
    catch {
        Write-Error "Error getting file: $($_.Exception.Message)"
        return $null
    }
}

# Использование
$fileContent = Get-FileFromTag -Workspace "your-workspace" -RepoSlug "your-repo" -TagName "v1.0.0" -FilePath "README.md" -Token "your-token"
if ($fileContent) {
    Write-Host "File content:" -ForegroundColor Green
    $fileContent
}
4. Полный пример с обработкой ошибок и выводом
powershell
# Полный скрипт для работы с тегами
function Get-BitbucketTagsDetailed {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Workspace,
        
        [Parameter(Mandatory=$true)]
        [string]$RepoSlug,
        
        [Parameter(Mandatory=$true)]
        [string]$Token,
        
        [string]$OutputFormat = "table"
    )
    
    # Базовая настройка
    $baseUrl = "https://api.bitbucket.org/2.0/repositories/$Workspace/$RepoSlug"
    $headers = @{
        "Authorization" = "Bearer $Token"
    }
    
    Write-Host "Fetching tags from $Workspace/$RepoSlug..." -ForegroundColor Yellow
    
    # Получаем все теги
    $url = "$baseUrl/refs/tags"
    $allTags = @()
    
    try {
        do {
            $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
            $allTags += $response.values
            $url = $response.next
        } while ($url)
        
        Write-Host "Found $($allTags.Count) tags" -ForegroundColor Green
        
        # Форматируем вывод
        $formattedTags = $allTags | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.name
                Commit = $_.target.hash.Substring(0, 12)
                Date = ([DateTime]$_.date).ToString("yyyy-MM-dd HH:mm:ss")
                Author = $_.target.author.raw
                Message = if ($_.target.message) { $_.target.message.Substring(0, 50) + "..." } else { "N/A" }
            }
        }
        
        # Вывод в зависимости от формата
        switch ($OutputFormat) {
            "table" { 
                $formattedTags | Format-Table -AutoSize 
            }
            "list" { 
                $formattedTags | Format-List 
            }
            "json" { 
                $formattedTags | ConvertTo-Json -Depth 2 
            }
            "csv" { 
                $formattedTags | Export-Csv -Path "tags.csv" -NoTypeInformation
                Write-Host "Tags exported to tags.csv" -ForegroundColor Green
            }
            default { 
                $formattedTags | Format-Table -AutoSize 
            }
        }
        
        return $formattedTags
    }
    catch {
        Write-Error "Failed to get tags: $($_.Exception.Message)"
        return $null
    }
}

# Использование
$tags = Get-BitbucketTagsDetailed -Workspace "your-workspace" -RepoSlug "your-repo" -Token "your-token" -OutputFormat "table"
5. Пример с Basic Authentication
powershell
# Если используете логин/пароль вместо токена
function Get-BitbucketTagsWithAuth {
    param(
        [string]$Workspace,
        [string]$RepoSlug,
        [string]$Username,
        [string]$Password
    )
    
    $url = "https://api.bitbucket.org/2.0/repositories/$Workspace/$RepoSlug/refs/tags"
    
    # Создаем Basic Auth header
    $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Username`:$Password"))
    $headers = @{
        "Authorization" = "Basic $base64Auth"
    }
    
    $allTags = @()
    
    do {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        $allTags += $response.values
        $url = $response.next
    } while ($url)
    
    return $allTags
}

# Использование с логином/паролем
$tags = Get-BitbucketTagsWithAuth -Workspace "your-workspace" -RepoSlug "your-repo" -Username "your-username" -Password "your-password"
6. Экспорт тегов в файл
powershell
function Export-BitbucketTags {
    param(
        [string]$Workspace,
        [string]$RepoSlug,
        [string]$Token,
        [string]$OutputPath = "bitbucket_tags.json"
    )
    
    $tags = Get-BitbucketTags -Workspace $Workspace -RepoSlug $RepoSlug -Token $Token
    
    # Экспортируем в JSON
    $tags | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutputPath -Encoding UTF8
    
    Write-Host "Tags exported to $OutputPath" -ForegroundColor Green
    Write-Host "Total tags: $($tags.Count)" -ForegroundColor Yellow
}

# Использование
Export-BitbucketTags -Workspace "your-workspace" -RepoSlug "your-repo" -Token "your-token" -OutputPath "my_tags.json"
Запуск скрипта
Сохраните нужные функции в файл .ps1 и выполните:

powershell
# Точка входа скрипта
$workspace = "your-workspace"
$repo = "your-repository"
$token = "your-access-token"

# Получаем теги
$tags = Get-BitbucketTagsDetailed -Workspace $workspace -RepoSlug $repo -Token $token

# Выводим последние 5 тегов
$tags | Sort-Object Date -Descending | Select-Object -First 5 | Format-Table
Эти примеры покрывают основные сценарии работы с тегами Bitbucket через PowerShell с поддержкой пагинации и обработкой ошибок.