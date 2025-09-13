Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Создаем главную форму
$form = New-Object System.Windows.Forms.Form
$form.Text = "Поиск файлов"
$form.Size = New-Object System.Drawing.Size(500, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Метка для выбора папки
$labelPath = New-Object System.Windows.Forms.Label
$labelPath.Location = New-Object System.Drawing.Point(10, 20)
$labelPath.Size = New-Object System.Drawing.Size(200, 20)
$labelPath.Text = "Выберите папку для поиска:"
$form.Controls.Add($labelPath)

# Поле для отображения выбранной папки
$textBoxPath = New-Object System.Windows.Forms.TextBox
$textBoxPath.Location = New-Object System.Drawing.Point(10, 40)
$textBoxPath.Size = New-Object System.Drawing.Size(350, 20)
$textBoxPath.ReadOnly = $true
$form.Controls.Add($textBoxPath)

# Кнопка выбора папки
$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Location = New-Object System.Drawing.Point(370, 40)
$buttonBrowse.Size = New-Object System.Drawing.Size(100, 23)
$buttonBrowse.Text = "Обзор..."
$form.Controls.Add($buttonBrowse)

# Метка для выбора типа файлов
$labelFilter = New-Object System.Windows.Forms.Label
$labelFilter.Location = New-Object System.Drawing.Point(10, 80)
$labelFilter.Size = New-Object System.Drawing.Size(200, 20)
$labelFilter.Text = "Выберите тип файлов:"
$form.Controls.Add($labelFilter)

# Выпадающий список фильтров
$comboBoxFilter = New-Object System.Windows.Forms.ComboBox
$comboBoxFilter.Location = New-Object System.Drawing.Point(10, 100)
$comboBoxFilter.Size = New-Object System.Drawing.Size(200, 20)
$comboBoxFilter.DropDownStyle = "DropDownList"
# Добавляем популярные фильтры
$comboBoxFilter.Items.AddRange(@(
    "Все файлы (*.*)",
    "Текстовые файлы (*.txt)",
    "Документы Word (*.docx, *.doc)",
    "Таблицы Excel (*.xlsx, *.xls)",
    "PDF документы (*.pdf)",
    "Изображения (*.jpg, *.png, *.gif)",
    "Архивы (*.zip, *.rar, *.7z)",
    "Скрипты (*.ps1, *.bat, *.sh)",
    "Видео файлы (*.mp4, *.avi, *.mkv)",
    "Пользовательский фильтр..."
))
$comboBoxFilter.SelectedIndex = 0
$form.Controls.Add($comboBoxFilter)

# Поле для пользовательского фильтра
$textBoxCustomFilter = New-Object System.Windows.Forms.TextBox
$textBoxCustomFilter.Location = New-Object System.Drawing.Point(220, 100)
$textBoxCustomFilter.Size = New-Object System.Drawing.Size(150, 20)
$textBoxCustomFilter.Visible = $false
$textBoxCustomFilter.Text = "*.ext"
$form.Controls.Add($textBoxCustomFilter)

# Чекбокс для поиска в подпапках
$checkBoxRecurse = New-Object System.Windows.Forms.CheckBox
$checkBoxRecurse.Location = New-Object System.Drawing.Point(10, 140)
$checkBoxRecurse.Size = New-Object System.Drawing.Size(200, 20)
$checkBoxRecurse.Text = "Искать в подпапках"
$checkBoxRecurse.Checked = $true
$form.Controls.Add($checkBoxRecurse)

# Кнопка поиска
$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Location = New-Object System.Drawing.Point(10, 180)
$buttonSearch.Size = New-Object System.Drawing.Size(100, 30)
$buttonSearch.Text = "Поиск"
$buttonSearch.Enabled = $false
$form.Controls.Add($buttonSearch)

# Кнопка отмены
$buttonCancel = New-Object System.Windows.Forms.Button
$buttonCancel.Location = New-Object System.Drawing.Point(120, 180)
$buttonCancel.Size = New-Object System.Drawing.Size(100, 30)
$buttonCancel.Text = "Отмена"
$form.Controls.Add($buttonCancel)

# Список для отображения результатов
$listBoxResults = New-Object System.Windows.Forms.ListBox
$listBoxResults.Location = New-Object System.Drawing.Point(10, 220)
$listBoxResults.Size = New-Object System.Drawing.Size(460, 100)
$listBoxResults.Anchor = 'Bottom,Left,Right'
$listBoxResults.Visible = $false
$form.Controls.Add($listBoxResults)

# Метка для отображения количества найденных файлов
$labelResults = New-Object System.Windows.Forms.Label
$labelResults.Location = New-Object System.Drawing.Point(230, 180)
$labelResults.Size = New-Object System.Drawing.Size(200, 30)
$labelResults.Text = ""
$form.Controls.Add($labelResults)

# Обработчик выбора папки
$buttonBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Выберите папку для поиска"
    $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::Desktop
    
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textBoxPath.Text = $folderBrowser.SelectedPath
        $buttonSearch.Enabled = $true
    }
})

# Обработчик изменения выбора фильтра
$comboBoxFilter.Add_SelectedIndexChanged({
    if ($comboBoxFilter.SelectedItem -eq "Пользовательский фильтр...") {
        $textBoxCustomFilter.Visible = $true
    } else {
        $textBoxCustomFilter.Visible = $false
    }
})

# Функция для получения фильтра на основе выбора
function Get-FilterPattern {
    param($selectedItem)
    
    switch ($selectedItem) {
        "Все файлы (*.*)" { return "*.*" }
        "Текстовые файлы (*.txt)" { return "*.txt" }
        "Документы Word (*.docx, *.doc)" { return "*.doc*" }
        "Таблицы Excel (*.xlsx, *.xls)" { return "*.xls*" }
        "PDF документы (*.pdf)" { return "*.pdf" }
        "Изображения (*.jpg, *.png, *.gif)" { return "*.jpg", "*.png", "*.gif" }
        "Архивы (*.zip, *.rar, *.7z)" { return "*.zip", "*.rar", "*.7z" }
        "Скрипты (*.ps1, *.bat, *.sh)" { return "*.ps1", "*.bat", "*.sh" }
        "Видео файлы (*.mp4, *.avi, *.mkv)" { return "*.mp4", "*.avi", "*.mkv" }
        "Пользовательский фильтр..." { return $textBoxCustomFilter.Text }
        default { return "*.*" }
    }
}

# Обработчик кнопки поиска
$buttonSearch.Add_Click({
    $listBoxResults.Items.Clear()
    $listBoxResults.Visible = $true
    $labelResults.Text = "Поиск..."
    
    $path = $textBoxPath.Text
    $filterPattern = Get-FilterPattern $comboBoxFilter.SelectedItem
    $recurse = $checkBoxRecurse.Checked
    
    try {
        if ($filterPattern -is [array]) {
            # Если несколько фильтров
            $allFiles = @()
            foreach ($filter in $filterPattern) {
                if ($recurse) {
                    $files = Get-ChildItem -Path $path -Filter $filter -Recurse -File -ErrorAction SilentlyContinue
                } else {
                    $files = Get-ChildItem -Path $path -Filter $filter -File -ErrorAction SilentlyContinue
                }
                $allFiles += $files
            }
            $files = $allFiles | Sort-Object FullName
        } else {
            # Если один фильтр
            if ($recurse) {
                $files = Get-ChildItem -Path $path -Filter $filterPattern -Recurse -File -ErrorAction SilentlyContinue
            } else {
                $files = Get-ChildItem -Path $path -Filter $filterPattern -File -ErrorAction SilentlyContinue
            }
        }
        
        if ($files) {
            $labelResults.Text = "Найдено: $($files.Count) файлов"
            foreach ($file in $files) {
                $listBoxResults.Items.Add($file.FullName)
            }
        } else {
            $labelResults.Text = "Файлы не найдены"
        }
    } catch {
        $labelResults.Text = "Ошибка: $($_.Exception.Message)"
    }
})

# Обработчик кнопки отмены
$buttonCancel.Add_Click({
    $form.Close()
})

# Обработчик двойного клика по результату
$listBoxResults.Add_DoubleClick({
    if ($listBoxResults.SelectedItem) {
        try {
            Invoke-Item $listBoxResults.SelectedItem
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Не удалось открыть файл: $($_.Exception.Message)", "Ошибка", "OK", "Error")
        }
    }
})

# Показываем форму
[void]$form.ShowDialog()