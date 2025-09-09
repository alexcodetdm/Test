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