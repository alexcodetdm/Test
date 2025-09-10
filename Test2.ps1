1. Использование массивов и форматирования
powershell
# Подключение к базе данных и выполнение запроса
$connectionString = "Server=your_server;Database=your_db;Integrated Security=True"
$query = "SELECT Field1, Field2, Field3, Field4 FROM YourTable"

$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
$dataset = New-Object System.Data.DataSet

$adapter.Fill($dataset) | Out-Null
$connection.Close()

# Создание массива и добавление данных
$resultArray = @()

foreach ($row in $dataset.Tables[0].Rows) {
    # Формируем строку с нужными полями
    $line = "$($row.Field1),$($row.Field2),$($row.Field3),$($row.Field4)"
    $resultArray += $line
}

# Вывод результата
$resultArray
2. Использование PSCustomObject
powershell
# Более структурированный подход
$resultArray = @()

foreach ($row in $dataset.Tables[0].Rows) {
    $obj = [PSCustomObject]@{
        Field1 = $row.Field1
        Field2 = $row.Field2
        Field3 = $row.Field3
        Field4 = $row.Field4
    }
    $resultArray += $obj
}

# Вывод в одну строку с разделителями
$resultArray | ForEach-Object {
    "$($_.Field1)|$($_.Field2)|$($_.Field3)|$($_.Field4)"
}
3. Использование Join для форматирования
powershell
$resultArray = @()

foreach ($row in $dataset.Tables[0].Rows) {
    $fields = @($row.Field1, $row.Field2, $row.Field3, $row.Field4)
    $line = $fields -join ","
    $resultArray += $line
}

$resultArray
4. Компактная версия с Invoke-SqlCmd
powershell
# Если у вас есть модуль SqlServer
Import-Module SqlServer

$resultArray = @()
$results = Invoke-SqlCmd -ServerInstance "your_server" -Database "your_db" -Query "SELECT Field1, Field2, Field3, Field4 FROM YourTable"

foreach ($row in $results) {
    $line = "$($row.Field1);$($row.Field2);$($row.Field3);$($row.Field4)"
    $resultArray += $line
}

$resultArray
5. С обработкой NULL значений
powershell
$resultArray = @()

foreach ($row in $dataset.Tables[0].Rows) {
    # Заменяем NULL значения на пустые строки
    $f1 = if ([DBNull]::Value.Equals($row.Field1)) { "" } else { $row.Field1 }
    $f2 = if ([DBNull]::Value.Equals($row.Field2)) { "" } else { $row.Field2 }
    $f3 = if ([DBNull]::Value.Equals($row.Field3)) { "" } else { $row.Field3 }
    $f4 = if ([DBNull]::Value.Equals($row.Field4)) { "" } else { $row.Field4 }
    
    $line = "$f1,$f2,$f3,$f4"
    $resultArray += $line
}

$resultArray
Пример вывода:
text
value1,value2,value3,value4
test1,test2,test3,test4
data1,data2,data3,data4
Выберите подход, который лучше всего подходит для ваших нужд. Первый вариант наиболее простой и прямой, второй предоставляет больше гибкости для дальнейшей обработки данных.

Microsoft.SqlServer.Management.Smo.Server
вот несколько способов получить данные и добавить их в массив:

1. Базовый подход с Datatable
powershell
# Подключаем SMO assembly
Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=15.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

# Создаем объект сервера
$server = New-Object Microsoft.SqlServer.Management.Smo.Server "your_server_name"
$database = $server.Databases["your_database_name"]

# Выполняем запрос
$result = $database.ExecuteWithResults("SELECT Field1, Field2, Field3, Field4 FROM YourTable")

# Создаем массив и добавляем данные
$resultArray = @()

foreach ($row in $result.Tables[0].Rows) {
    $line = "$($row.Field1),$($row.Field2),$($row.Field3),$($row.Field4)"
    $resultArray += $line
}

# Выводим результат
$resultArray
2. Использование Invoke-SqlCmd через SMO
powershell
# Альтернативный способ с Datatable
$dataTable = New-Object System.Data.DataTable
$dataTable = $database.ExecuteWithResults("SELECT Field1, Field2, Field3, Field4 FROM YourTable").Tables[0]

$resultArray = @()

foreach ($row in $dataTable.Rows) {
    $fields = @(
        $row["Field1"],
        $row["Field2"], 
        $row["Field3"],
        $row["Field4"]
    )
    $line = $fields -join "|"
    $resultArray += $line
}

$resultArray
3. С обработкой NULL значений
powershell
$resultArray = @()
$result = $database.ExecuteWithResults("SELECT Field1, Field2, Field3, Field4 FROM YourTable")

foreach ($row in $result.Tables[0].Rows) {
    # Функция для обработки NULL значений
    function Get-ValueOrEmpty {
        param($value)
        if ([DBNull]::Value.Equals($value)) { "" } else { $value }
    }
    
    $line = "{0},{1},{2},{3}" -f `
        (Get-ValueOrEmpty $row.Field1),
        (Get-ValueOrEmpty $row.Field2),
        (Get-ValueOrEmpty $row.Field3),
        (Get-ValueOrEmpty $row.Field4)
    
    $resultArray += $line
}

$resultArray
4. Компактная версия с Select-Object
powershell
$result = $database.ExecuteWithResults("SELECT Field1, Field2, Field3, Field4 FROM YourTable")

$resultArray = $result.Tables[0].Rows | ForEach-Object {
    "$($_.Field1);$($_.Field2);$($_.Field3);$($_.Field4)"
}

$resultArray
5. Создание объекта с кастомными свойствами
powershell
$resultArray = @()
$result = $database.ExecuteWithResults("SELECT Field1, Field2, Field3, Field4 FROM YourTable")

foreach ($row in $result.Tables[0].Rows) {
    $item = New-Object PSObject -Property @{
        Combined = "$($row.Field1)-$($row.Field2)-$($row.Field3)-$($row.Field4)"
        Field1 = $row.Field1
        Field2 = $row.Field2
        Field3 = $row.Field3
        Field4 = $row.Field4
    }
    $resultArray += $item.Combined
}

$resultArray
6. Для работы с большими объемами данных (более эффективно)
powershell
# Используем ArrayList для лучшей производительности при больших объемах данных
$resultList = [System.Collections.ArrayList]@()
$result = $database.ExecuteWithResults("SELECT Field1, Field2, Field3, Field4 FROM YourTable")

foreach ($row in $result.Tables[0].Rows) {
    $line = "{0}|{1}|{2}|{3}" -f $row.Field1, $row.Field2, $row.Field3, $row.Field4
    [void]$resultList.Add($line)
}

# Конвертируем обратно в обычный массив если нужно
$resultArray = @($resultList)
$resultArray
Пример использования с параметрами:
powershell
# Подключение к серверу
$serverName = "SQLSERVER01"
$dbName = "AdventureWorks"
$query = "SELECT FirstName, LastName, Email, Phone FROM Customers WHERE City = 'London'"

$server = New-Object Microsoft.SqlServer.Management.Smo.Server $serverName
$database = $server.Databases[$dbName]

$resultArray = @()
$data = $database.ExecuteWithResults($query)

foreach ($row in $data.Tables[0].Rows) {
    $line = "$($row.FirstName) $($row.LastName) - $($row.Email) - $($row.Phone)"
    $resultArray += $line
}

# Вывод результатов
$resultArray | ForEach-Object { Write-Output $_ }

¬ PowerShell есть несколько способов получить названи€ файлов из папки в массив:

1. ѕростой способ с Get-ChildItem
powershell
# ѕолучить только имена файлов (без полного пути)
$fileNames = Get-ChildItem -Path "C:\Your\Folder" -File | Select-Object -ExpandProperty Name

# ¬ывести результат
$fileNames
2. ѕолучить массив с полными пут€ми
powershell
# ѕолучить полные пути к файлам
$filePaths = Get-ChildItem -Path "C:\Your\Folder" -File | Select-Object -ExpandProperty FullName

$filePaths
3. “олько дл€ определенного типа файлов
powershell
# “олько txt файлы
$txtFiles = Get-ChildItem -Path "C:\Your\Folder" -Filter "*.txt" | Select-Object -ExpandProperty Name

# “олько excel файлы
$excelFiles = Get-ChildItem -Path "C:\Your\Folder" -Filter "*.xlsx" | Select-Object -ExpandProperty Name
4. — использованием ForEach-Object
powershell
$fileNames = @()
Get-ChildItem -Path "C:\Your\Folder" -File | ForEach-Object {
    $fileNames += $_.Name
}

$fileNames
5. Ѕолее эффективный способ с ArrayList
powershell
# ƒл€ больших папок лучше использовать ArrayList
$fileList = [System.Collections.ArrayList]@()
Get-ChildItem -Path "C:\Your\Folder" -File | ForEach-Object {
    [void]$fileList.Add($_.Name)
}

#  онвертируем в обычный массив если нужно
$fileNames = @($fileList)
$fileNames
6. — рекурсивным поиском (включа€ подпапки)
powershell
# »скать во всех подпапках
$allFiles = Get-ChildItem -Path "C:\Your\Folder" -File -Recurse | Select-Object -ExpandProperty Name

$allFiles
7. — фильтрацией по атрибутам
powershell
# “олько скрытые файлы
$hiddenFiles = Get-ChildItem -Path "C:\Your\Folder" -File -Hidden | Select-Object -ExpandProperty Name

# “олько системные файлы
$systemFiles = Get-ChildItem -Path "C:\Your\Folder" -File -System | Select-Object -ExpandProperty Name
8. — сортировкой
powershell
# ќтсортировать по имени
$sortedFiles = Get-ChildItem -Path "C:\Your\Folder" -File | 
               Sort-Object Name | 
               Select-Object -ExpandProperty Name

# ќтсортировать по дате изменени€ (сначала новые)
$newestFiles = Get-ChildItem -Path "C:\Your\Folder" -File | 
               Sort-Object LastWriteTime -Descending | 
               Select-Object -ExpandProperty Name
9.  омпактна€ запись
powershell
# —амый короткий вариант
$files = (Get-ChildItem -Path "C:\Your\Folder" -File).Name
$files
10. ѕолный пример с обработкой ошибок
powershell
try {
    $folderPath = "C:\Your\Folder"
    
    # ѕровер€ем существование папки
    if (Test-Path $folderPath -PathType Container) {
        $fileNames = Get-ChildItem -Path $folderPath -File -ErrorAction Stop | 
                    Select-Object -ExpandProperty Name
        
        Write-Host "Ќайдено файлов: $($fileNames.Count)"
        $fileNames
    }
    else {
        Write-Warning "ѕапка $folderPath не существует!"
    }
}
catch {
    Write-Error "ќшибка при получении списка файлов: $($_.Exception.Message)"
}
11. —охранение в файл
powershell
# ѕолучить имена файлов и сохранить в текстовый файл
$fileNames = Get-ChildItem -Path "C:\Your\Folder" -File | Select-Object -ExpandProperty Name
$fileNames | Out-File -FilePath "C:\file_list.txt"

# »ли одной строкой
(Get-ChildItem -Path "C:\Your\Folder" -File).Name | Out-File "C:\file_list.txt"
ѕример вывода:
text
file1.txt
document.docx
image.jpg
script.ps1
data.xlsx
—овет: ƒл€ работы с большими папками используйте вариант с ArrayList (пункт 5), так как он более эффективен по пам€ти.

—равнить два массива System.Collections.ArrayList и вывести отличи€
¬ PowerShell есть несколько способов сравнить два ArrayList и найти отличи€. ¬от основные методы:

1. »спользование Compare-Object (самый простой способ)
powershell
# —оздаем два ArrayList дл€ примера
$list1 = [System.Collections.ArrayList]@('file1.txt', 'file2.txt', 'file3.txt', 'file5.txt')
$list2 = [System.Collections.ArrayList]@('file2.txt', 'file3.txt', 'file4.txt', 'file6.txt')

# —равниваем и находим отличи€
$differences = Compare-Object -ReferenceObject $list1 -DifferenceObject $list2

# ¬ыводим результат
$differences
2. Ѕолее детализированное сравнение
powershell
$comparison = Compare-Object -ReferenceObject $list1 -DifferenceObject $list2

Write-Host "=== –ј«Ћ»„»я ћ≈∆ƒ” ћј——»¬јћ» ===" -ForegroundColor Yellow

foreach ($item in $comparison) {
    if ($item.SideIndicator -eq '=>') {
        Write-Host "“олько во втором массиве: $($item.InputObject)" -ForegroundColor Green
    }
    elseif ($item.SideIndicator -eq '<=') {
        Write-Host "“олько в первом массиве: $($item.InputObject)" -ForegroundColor Red
    }
}
3. –азделение на отдельные массивы различий
powershell
$comparison = Compare-Object -ReferenceObject $list1 -DifferenceObject $list2

# Ёлементы только в первом массиве
$onlyInFirst = $comparison | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -ExpandProperty InputObject

# Ёлементы только во втором массиве
$onlyInSecond = $comparison | Where-Object { $_.SideIndicator -eq '=>' } | Select-Object -ExpandProperty InputObject

# ќбщие элементы
$commonItems = $list1 | Where-Object { $list2 -contains $_ }

Write-Host "“олько в первом массиве: $($onlyInFirst -join ', ')" -ForegroundColor Red
Write-Host "“олько во втором массиве: $($onlyInSecond -join ', ')" -ForegroundColor Green
Write-Host "ќбщие элементы: $($commonItems -join ', ')" -ForegroundColor Blue
4. — использованием методов .NET
powershell
# Ёлементы только в первом массиве
$onlyInFirst = $list1 | Where-Object { $list2 -notcontains $_ }

# Ёлементы только во втором массиве
$onlyInSecond = $list2 | Where-Object { $list1 -notcontains $_ }

# ќбщие элементы
$commonItems = $list1 | Where-Object { $list2 -contains $_ }

Write-Host "=== –≈«”Ћ№“ј“џ —–ј¬Ќ≈Ќ»я ===" -ForegroundColor Yellow
Write-Host "“олько в list1 ($($onlyInFirst.Count)): " -NoNewline -ForegroundColor Red
Write-Host ($onlyInFirst -join ', ')
Write-Host "“олько в list2 ($($onlyInSecond.Count)): " -NoNewline -ForegroundColor Green
Write-Host ($onlyInSecond -join ', ')
Write-Host "ќбщие элементы ($($commonItems.Count)): " -NoNewline -ForegroundColor Blue
Write-Host ($commonItems -join ', ')
5. ‘ункци€ дл€ удобного сравнени€
powershell
function Compare-ArrayLists {
    param(
        [System.Collections.ArrayList]$FirstList,
        [System.Collections.ArrayList]$SecondList,
        [string]$FirstName = "ѕервый массив",
        [string]$SecondName = "¬торой массив"
    )
    
    $comparison = Compare-Object -ReferenceObject $FirstList -DifferenceObject $SecondList
    
    $onlyInFirst = $comparison | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -ExpandProperty InputObject
    $onlyInSecond = $comparison | Where-Object { $_.SideIndicator -eq '=>' } | Select-Object -ExpandProperty InputObject
    $commonItems = $FirstList | Where-Object { $SecondList -contains $_ }
    
    Write-Host "`n=== —–ј¬Ќ≈Ќ»≈: $FirstName vs $SecondName ===" -ForegroundColor Yellow
    Write-Host "Ёлементов в $FirstName`: $($FirstList.Count)" -ForegroundColor Gray
    Write-Host "Ёлементов в $SecondName`: $($SecondList.Count)" -ForegroundColor Gray
    Write-Host "ќбщих элементов: $($commonItems.Count)" -ForegroundColor Blue
    Write-Host "”никальных в $FirstName`: $($onlyInFirst.Count)" -ForegroundColor Red
    Write-Host "”никальных в $SecondName`: $($onlyInSecond.Count)" -ForegroundColor Green
    
    if ($onlyInFirst) {
        Write-Host "`n“олько в $FirstName`: " -ForegroundColor Red -NoNewline
        Write-Host ($onlyInFirst -join ', ')
    }
    
    if ($onlyInSecond) {
        Write-Host "“олько в $SecondName`: " -ForegroundColor Green -NoNewline
        Write-Host ($onlyInSecond -join ', ')
    }
    
    return @{
        OnlyInFirst = $onlyInFirst
        OnlyInSecond = $onlyInSecond
        Common = $commonItems
    }
}

# »спользование функции
$result = Compare-ArrayLists -FirstList $list1 -SecondList $list2 -FirstName "»сходные файлы" -SecondName "Ќовые файлы"
6. —равнение без учета регистра
powershell
# ≈сли нужно сравнение без учета регистра
$caseInsensitiveCompare = Compare-Object -ReferenceObject $list1 -DifferenceObject $list2 -CaseSensitive:$false
$caseInsensitiveCompare
7. —инхронное сравнение с индексами
powershell
# ƒл€ сравнени€ по позици€м (если пор€док важен)
for ($i = 0; $i -lt [Math]::Max($list1.Count, $list2.Count); $i++) {
    $item1 = if ($i -lt $list1.Count) { $list1[$i] } else { "Ќ≈“ ЁЋ≈ћ≈Ќ“ј" }
    $item2 = if ($i -lt $list2.Count) { $list2[$i] } else { "Ќ≈“ ЁЋ≈ћ≈Ќ“ј" }
    
    if ($item1 -ne $item2) {
        Write-Host "–азличие в позиции $i : $item1 != $item2" -ForegroundColor Yellow
    }
}
8. Ёкспорт результатов в файл
powershell
$comparison = Compare-Object -ReferenceObject $list1 -DifferenceObject $list2

$report = @"
=== ќ“„≈“ ќ —–ј¬Ќ≈Ќ»» ћј——»¬ќ¬ ===
ƒата сравнени€: $(Get-Date)
–азмер первого массива: $($list1.Count)
–азмер второго массива: $($list2.Count)

Ёлементы только в первом массиве:
$($comparison | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object { "  - $($_.InputObject)" } | Out-String)

Ёлементы только во втором массиве:
$($comparison | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object { "  - $($_.InputObject)" } | Out-String)
"@

$report | Out-File -FilePath "comparison_report.txt"
Write-Host "ќтчет сохранен в comparison_report.txt"
ѕример вывода:
text
InputObject SideIndicator
----------- -------------
file1.txt   <=
file5.txt   <=
file4.txt   =>
file6.txt   =>
–екомендации:

»спользуйте Compare-Object дл€ большинства случаев - это самый надежный метод

ƒл€ больших массивов метод с -notcontains может быть медленнее

‘ункци€ Compare-ArrayLists предоставл€ет наиболее читаемый результат

¬от несколько способов добавить имена файлов из папки в System.Collections.ArrayList:

1. Ѕазовый способ (самый простой)
powershell
# —оздаем ArrayList
$fileList = [System.Collections.ArrayList]@()

# ѕолучаем имена файлов и добавл€ем в ArrayList
Get-ChildItem -Path "C:\Your\Folder" -File | ForEach-Object {
    [void]$fileList.Add($_.Name)
}

# ¬ыводим результат
$fileList
2.  омпактна€ верси€
powershell
$fileList = [System.Collections.ArrayList]@(
    (Get-ChildItem -Path "C:\Your\Folder" -File).Name
)

$fileList
3. — обработкой ошибок
powershell
$folderPath = "C:\Your\Folder"
$fileList = [System.Collections.ArrayList]@()

try {
    if (Test-Path $folderPath -PathType Container) {
        $files = Get-ChildItem -Path $folderPath -File -ErrorAction Stop
        
        foreach ($file in $files) {
            [void]$fileList.Add($file.Name)
        }
        
        Write-Host "ƒобавлено файлов: $($fileList.Count)" -ForegroundColor Green
    }
    else {
        Write-Warning "ѕапка $folderPath не существует!"
    }
}
catch {
    Write-Error "ќшибка: $($_.Exception.Message)"
}

$fileList
4. — рекурсивным поиском (включа€ подпапки)
powershell
$fileList = [System.Collections.ArrayList]@()

Get-ChildItem -Path "C:\Your\Folder" -File -Recurse | ForEach-Object {
    [void]$fileList.Add($_.Name)
}

$fileList
5. — фильтрацией по расширению
powershell
$fileList = [System.Collections.ArrayList]@()

# “олько txt файлы
Get-ChildItem -Path "C:\Your\Folder" -Filter "*.txt" -File | ForEach-Object {
    [void]$fileList.Add($_.Name)
}

$fileList
6. — дополнительной информацией о файлах
powershell
$fileList = [System.Collections.ArrayList]@()

Get-ChildItem -Path "C:\Your\Folder" -File | ForEach-Object {
    # —оздаем объект с информацией о файле
    $fileInfo = @{
        Name = $_.Name
        Size = $_.Length
        LastModified = $_.LastWriteTime
        Extension = $_.Extension
    }
    
    [void]$fileList.Add($fileInfo)
}

# ¬ыводим результат
$fileList | ForEach-Object {
    Write-Host "‘айл: $($_.Name), –азмер: $($_.Size) байт, –асширение: $($_.Extension)"
}
7. — сортировкой по имени
powershell
$fileList = [System.Collections.ArrayList]@()

Get-ChildItem -Path "C:\Your\Folder" -File | 
Sort-Object Name | 
ForEach-Object {
    [void]$fileList.Add($_.Name)
}

$fileList
8. ”ниверсальна€ функци€
powershell
function Get-FileListToArrayList {
    param(
        [string]$Path = ".",
        [switch]$Recursive,
        [string]$Filter = "*",
        [switch]$FullName
    )
    
    $fileList = [System.Collections.ArrayList]@()
    $params = @{
        Path = $Path
        Filter = $Filter
        File = $true
    }
    
    if ($Recursive) {
        $params.Recurse = $true
    }
    
    try {
        $files = Get-ChildItem @params -ErrorAction Stop
        
        foreach ($file in $files) {
            if ($FullName) {
                [void]$fileList.Add($file.FullName)
            }
            else {
                [void]$fileList.Add($file.Name)
            }
        }
    }
    catch {
        Write-Error "ќшибка при получении списка файлов: $($_.Exception.Message)"
    }
    
    return $fileList
}

# »спользование функции
$files = Get-FileListToArrayList -Path "C:\Your\Folder" -Recursive
$files
9. — исключением определенных файлов
powershell
$fileList = [System.Collections.ArrayList]@()
$excludeExtensions = @('.tmp', '.log', '.bak')

Get-ChildItem -Path "C:\Your\Folder" -File | ForEach-Object {
    if ($excludeExtensions -notcontains $_.Extension) {
        [void]$fileList.Add($_.Name)
    }
}

$fileList
10. — ограничением по количеству файлов
powershell
$fileList = [System.Collections.ArrayList]@()
$maxFiles = 100
$count = 0

Get-ChildItem -Path "C:\Your\Folder" -File | ForEach-Object {
    if ($count -lt $maxFiles) {
        [void]$fileList.Add($_.Name)
        $count++
    }
}

Write-Host "ƒобавлено $count файлов из $((Get-ChildItem -Path "C:\Your\Folder" -File).Count)"
$fileList
11. —охранение в файл
powershell
$fileList = [System.Collections.ArrayList]@()

Get-ChildItem -Path "C:\Your\Folder" -File | ForEach-Object {
    [void]$fileList.Add($_.Name)
}

# —охран€ем в файл
$fileList | Out-File -FilePath "C:\file_list.txt"

Write-Host "—писок файлов сохранен в C:\file_list.txt"
ѕример вывода:
text
Count Capacity
----- --------
   25       32

# ƒл€ просмотра содержимого:
$fileList | Format-Table -AutoSize
ѕреимущества использовани€ ArrayList:

Ѕыстрее работает с большими количествами файлов

Ћегко добавл€ть и удал€ть элементы

ѕоддерживает все методы коллекций .NET

¬ажно: »спользуйте [void] перед $fileList.Add() чтобы подавить вывод номера индекса при добавлении элементов.

Вот пример скрипта для удаления файлов с подтверждением:

1. Полный скрипт с подтверждением
powershell
# Создаем массив с файлами для удаления
$filesToDelete = [System.Collections.ArrayList]@(
    "C:\temp\file1.txt",
    "C:\temp\old_file.log",
    "C:\temp\backup.bak",
    "C:\temp\temp_data.tmp"
)

function Remove-FilesWithConfirmation {
    param(
        [System.Collections.ArrayList]$FileList
    )
    
    Write-Host "=== СКРИПТ УДАЛЕНИЯ ФАЙЛОВ ===" -ForegroundColor Yellow
    Write-Host "Найдено файлов для удаления: $($FileList.Count)" -ForegroundColor Cyan
    
    # Показываем список файлов
    Write-Host "`nСписок файлов для удаления:" -ForegroundColor Green
    for ($i = 0; $i -lt $FileList.Count; $i++) {
        Write-Host "$($i+1). $($FileList[$i])" -ForegroundColor Gray
    }
    
    # Запрос подтверждения
    Write-Host "`n" -NoNewline
    $confirmation = Read-Host "Вы уверены, что хотите удалить эти файлы? (y/N)"
    
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y' -and $confirmation -ne 'д' -and $confirmation -ne 'Д') {
        Write-Host "Удаление отменено." -ForegroundColor Red
        return
    }
    
    # Подтверждение для каждого файла
    $confirmEach = Read-Host "Подтверждать удаление каждого файла отдельно? (y/N)"
    $confirmIndividual = ($confirmEach -eq 'y' -or $confirmEach -eq 'Y' -or $confirmEach -eq 'д' -or $confirmEach -eq 'Д')
    
    $deletedCount = 0
    $failedCount = 0
    $skippedCount = 0
    
    # Удаляем файлы
    foreach ($filePath in $FileList) {
        if (-not (Test-Path $filePath -PathType Leaf)) {
            Write-Host "Файл не найден: $filePath" -ForegroundColor Yellow
            $skippedCount++
            continue
        }
        
        $fileInfo = Get-Item $filePath
        $fileSize = "{0:N2} MB" -f ($fileInfo.Length / 1MB)
        
        if ($confirmIndividual) {
            Write-Host "`nФайл: $($fileInfo.Name)" -ForegroundColor Cyan
            Write-Host "Размер: $fileSize" -ForegroundColor Gray
            Write-Host "Путь: $filePath" -ForegroundColor Gray
            
            $confirmFile = Read-Host "Удалить этот файл? (y/N)"
            if ($confirmFile -ne 'y' -and $confirmFile -ne 'Y' -and $confirmFile -ne 'д' -and $confirmFile -ne 'Д') {
                Write-Host "Пропускаем файл: $filePath" -ForegroundColor Yellow
                $skippedCount++
                continue
            }
        }
        
        try {
            Remove-Item -Path $filePath -Force -ErrorAction Stop
            Write-Host "УДАЛЕНО: $filePath" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "ОШИБКА при удалении $filePath : $($_.Exception.Message)" -ForegroundColor Red
            $failedCount++
        }
    }
    
    # Вывод результатов
    Write-Host "`n=== РЕЗУЛЬТАТЫ УДАЛЕНИЯ ===" -ForegroundColor Yellow
    Write-Host "Успешно удалено: $deletedCount" -ForegroundColor Green
    Write-Host "Не удалось удалить: $failedCount" -ForegroundColor Red
    Write-Host "Пропущено: $skippedCount" -ForegroundColor Yellow
    Write-Host "Всего обработано: $($FileList.Count)" -ForegroundColor Cyan
}

# Запускаем функцию удаления
Remove-FilesWithConfirmation -FileList $filesToDelete
2. Упрощенная версия
powershell
# Массив файлов для удаления
$filesToDelete = [System.Collections.ArrayList]@(
    "C:\temp\file1.txt",
    "C:\temp\file2.log",
    "C:\temp\file3.tmp"
)

Write-Host "Следующие файлы будут удалены:" -ForegroundColor Red
$filesToDelete | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }

$confirm = Read-Host "`nПродолжить удаление? (y/N)"

if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    $successCount = 0
    $errorCount = 0
    
    foreach ($file in $filesToDelete) {
        if (Test-Path $file) {
            try {
                Remove-Item $file -Force -ErrorAction Stop
                Write-Host "Удален: $file" -ForegroundColor Green
                $successCount++
            }
            catch {
                Write-Host "Ошибка: $file - $($_.Exception.Message)" -ForegroundColor Red
                $errorCount++
            }
        }
        else {
            Write-Host "Файл не найден: $file" -ForegroundColor Yellow
            $errorCount++
        }
    }
    
    Write-Host "`nУдалено: $successCount, Ошибок: $errorCount" -ForegroundColor Cyan
}
else {
    Write-Host "Удаление отменено." -ForegroundColor Green
}
3. Версия с логированием
powershell
$filesToDelete = [System.Collections.ArrayList]@(
    "C:\temp\file1.txt",
    "C:\temp\file2.log"
)

$logFile = "C:\temp\deletion_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Write-Log {
    param($Message, $Color = "White")
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

Write-Log "=== НАЧАЛО ПРОЦЕДУРЫ УДАЛЕНИЯ ===" "Yellow"

# Показываем файлы
Write-Log "Файлы для удаления:" "Cyan"
$filesToDelete | ForEach-Object { Write-Log "  - $_" "Gray" }

# Подтверждение
$confirm = Read-Host "`nПодтвердите удаление (y/N)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Log "Удаление отменено пользователем." "Green"
    exit
}

# Процесс удаления
foreach ($file in $filesToDelete) {
    if (Test-Path $file -PathType Leaf) {
        try {
            $fileInfo = Get-Item $file
            $size = "{0:N2} MB" -f ($fileInfo.Length / 1MB)
            
            Remove-Item $file -Force -ErrorAction Stop
            Write-Log "УСПЕХ: $file ($size)" "Green"
        }
        catch {
            Write-Log "ОШИБКА: $file - $($_.Exception.Message)" "Red"
        }
    }
    else {
        Write-Log "НЕ НАЙДЕН: $file" "Yellow"
    }
}

Write-Log "=== ПРОЦЕДУРА УДАЛЕНИЯ ЗАВЕРШЕНА ===" "Yellow"
Write-Log "Лог сохранен в: $logFile" "Cyan"
4. Функция для многократного использования
powershell
function Invoke-SafeFileDeletion {
    param(
        [System.Collections.ArrayList]$FilePaths,
        [switch]$ConfirmEachFile,
        [string]$LogPath = ""
    )
    
    # Создаем лог файл если указан
    if ($LogPath) {
        $logStream = [System.IO.StreamWriter]::new($LogPath, $true)
        $logStream.WriteLine("$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Начало удаления файлов")
    }
    
    try {
        Write-Host "Найдено файлов: $($FilePaths.Count)" -ForegroundColor Cyan
        
        # Общее подтверждение
        Write-Host "`nФайлы для удаления:" -ForegroundColor Yellow
        $FilePaths | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        
        $confirm = Read-Host "`nПродолжить удаление? (y/N)"
        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host "Отменено." -ForegroundColor Green
            if ($LogPath) { $logStream.WriteLine("Отменено пользователем") }
            return
        }
        
        $results = @{
            Deleted = 0
            Failed = 0
            Skipped = 0
        }
        
        # Удаление файлов
        foreach ($file in $FilePaths) {
            if (-not (Test-Path $file -PathType Leaf)) {
                $msg = "Файл не найден: $file"
                Write-Host $msg -ForegroundColor Yellow
                if ($LogPath) { $logStream.WriteLine($msg) }
                $results.Skipped++
                continue
            }
            
            if ($ConfirmEachFile) {
                $fileConfirm = Read-Host "Удалить файл '$file'? (y/N)"
                if ($fileConfirm -ne 'y' -and $fileConfirm -ne 'Y') {
                    $msg = "Пропущен: $file"
                    Write-Host $msg -ForegroundColor Yellow
                    if ($LogPath) { $logStream.WriteLine($msg) }
                    $results.Skipped++
                    continue
                }
            }
            
            try {
                Remove-Item $file -Force -ErrorAction Stop
                $msg = "Удален: $file"
                Write-Host $msg -ForegroundColor Green
                if ($LogPath) { $logStream.WriteLine($msg) }
                $results.Deleted++
            }
            catch {
                $msg = "Ошибка: $file - $($_.Exception.Message)"
                Write-Host $msg -ForegroundColor Red
                if ($LogPath) { $logStream.WriteLine($msg) }
                $results.Failed++
            }
        }
        
        # Итоги
        $summary = "Итог: Удалено $($results.Deleted), Ошибок $($results.Failed), Пропущено $($results.Skipped)"
        Write-Host "`n$summary" -ForegroundColor Cyan
        if ($LogPath) { $logStream.WriteLine($summary) }
        
    }
    finally {
        if ($LogPath) {
            $logStream.WriteLine("$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Завершение")
            $logStream.Close()
            Write-Host "Лог сохранен: $LogPath" -ForegroundColor Gray
        }
    }
}

# Использование функции
$files = [System.Collections.ArrayList]@("C:\temp\test1.txt", "C:\temp\test2.txt")
Invoke-SafeFileDeletion -FilePaths $files -ConfirmEachFile -LogPath "C:\temp\deletion_log.txt"
5. Пример с реальными файлами из папки
powershell
# Получаем файлы из папки для удаления
$folderPath = "C:\temp\old_files"
$filesToDelete = [System.Collections.ArrayList]@()

if (Test-Path $folderPath) {
    Get-ChildItem $folderPath -File | ForEach-Object {
        [void]$filesToDelete.Add($_.FullName)
    }
}

if ($filesToDelete.Count -gt 0) {
    Write-Host "Найдено файлов в $folderPath : $($filesToDelete.Count)" -ForegroundColor Cyan
    
    $confirm = Read-Host "Удалить все эти файлы? (y/N)"
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        foreach ($file in $filesToDelete) {
            try {
                Remove-Item $file -Force
                Write-Host "Удален: $(Split-Path $file -Leaf)" -ForegroundColor Green
            }
            catch {
                Write-Host "Ошибка при удалении $file" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "Удаление отменено" -ForegroundColor Yellow
    }
}
else {
    Write-Host "Файлы для удаления не найдены" -ForegroundColor Yellow
}
