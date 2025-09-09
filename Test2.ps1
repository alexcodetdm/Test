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