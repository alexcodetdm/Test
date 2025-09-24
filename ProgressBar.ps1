Вот несколько способов вывести счетчик ожидания в PowerShell:

1. Простой счетчик с очисткой строки
powershell
$seconds = 10
for ($i = $seconds; $i -gt 0; $i--) {
    Write-Host "Ожидание: $i секунд" -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "`r" -NoNewline  # Возврат каретки в начало строки
}
Write-Host "Ожидание завершено!          "
2. Счетчик с прогресс-баром
powershell
function Show-Countdown {
    param(
        [int]$Seconds = 10,
        [string]$Message = "Ожидание"
    )
    
    for ($i = $Seconds; $i -gt 0; $i--) {
        $percent = (($Seconds - $i) / $Seconds) * 100
        $progressParams = @{
            Activity = $Message
            Status = "Осталось: $i сек"
            PercentComplete = $percent
            CurrentOperation = "Выполняется ожидание..."
        }
        Write-Progress @progressParams
        Start-Sleep -Seconds 1
    }
    Write-Progress -Activity $Message -Completed
}

# Использование
Show-Countdown -Seconds 15 -Message "Подготовка системы"
3. Графический счетчик с символами
powershell
$totalSeconds = 30
$blockChar = "█"
$emptyChar = "▒"

for ($i = $totalSeconds; $i -gt 0; $i--) {
    $progress = $totalSeconds - $i
    $percent = [math]::Round(($progress / $totalSeconds) * 100)
    $blocks = [math]::Round(($progress / $totalSeconds) * 20)
    $progressBar = $blockChar * $blocks + $emptyChar * (20 - $blocks)
    
    Write-Host "`r[$progressBar] $percent% ($i сек осталось)" -NoNewline -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}
Write-Host "`r[████████████████████] 100% Завершено!          " -ForegroundColor Green
4. Многострочный счетчик
powershell
$waitTime = 60  # 1 минута
$startTime = Get-Date
$endTime = $startTime.AddSeconds($waitTime)

while ((Get-Date) -lt $endTime) {
    $remaining = ($endTime - (Get-Date)).TotalSeconds
    $elapsed = ($waitTime - $remaining)
    $percent = ($elapsed / $waitTime) * 100
    
    Clear-Host
    Write-Host "=== Счетчик ожидания ===" -ForegroundColor Cyan
    Write-Host "Прошло времени: $([math]::Round($elapsed)) сек" -ForegroundColor Yellow
    Write-Host "Осталось времени: $([math]::Round($remaining)) сек" -ForegroundColor Green
    Write-Host "Завершено: $([math]::Round($percent))%"
    Write-Host "Окончание: $($endTime.ToString('HH:mm:ss'))"
    
    Start-Sleep -Seconds 1
}

Write-Host "Ожидание завершено!" -ForegroundColor Green
5. Универсальная функция с параметрами
powershell
function Start-Countdown {
    param(
        [Parameter(Mandatory=$true)]
        [int]$Seconds,
        
        [string]$Message = "Ожидание выполнения",
        [switch]$ShowProgressBar,
        [switch]$ShowSpinner
    )
    
    if ($ShowProgressBar) {
        for ($i = $Seconds; $i -gt 0; $i--) {
            $percent = (($Seconds - $i) / $Seconds) * 100
            Write-Progress -Activity $Message -Status "$i сек осталось" -PercentComplete $percent
            Start-Sleep -Seconds 1
        }
        Write-Progress -Activity $Message -Completed
    }
    else {
        for ($i = $Seconds; $i -gt 0; $i--) {
            $spinner = if ($ShowSpinner) { @('|', '/', '-', '\')[$i % 4] } else { "" }
            Write-Host "`r$Message $spinner $i сек " -NoNewline -ForegroundColor Cyan
            Start-Sleep -Seconds 1
        }
        Write-Host "`r$Message завершено!          " -ForegroundColor Green
    }
}

# Примеры использования:
Start-Countdown -Seconds 10 -Message "Загрузка данных"
Start-Countdown -Seconds 15 -ShowProgressBar -Message "Обработка файлов"
Start-Countdown -Seconds 5 -ShowSpinner -Message "Подключение"
Советы по использованию:
Write-Progress - лучший вариант для длительных операций

Возврат каретки (\r) - для обновления одной строки

Clear-Host - для полного обновления экрана

Используйте цвета для лучшей визуализации

Выберите подходящий вариант в зависимости от ваших потребностей!