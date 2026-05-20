# BlackWhite UI Library

Минималистичная premium Roblox UI Library для executor среды.
Черно-белая тема, плавные анимации, чистый API.

---

## Быстрый старт

```lua
local Library = loadstring(game:HttpGet("URL_TO_LIBRARY"))()

local Window = Library:CreateWindow({
    Title     = "MyScript",
    Size      = UDim2.fromOffset(580, 460),
    Executor  = "Solara",
    ToggleKey = Enum.KeyCode.RightShift,
})

local Tab = Window:CreateTab("Main")

Tab:CreateToggle({
    Name         = "Feature",
    CurrentValue = false,
    Callback     = function(v) print(v) end
})
```

---

## API Reference

### Library

| Метод | Описание |
|---|---|
| `Library:CreateWindow(opts)` | Создать окно |
| `Library:Notify({ Title, Content, Duration })` | Уведомление |
| `Library:SaveConfig(name)` | Сохранить конфиг |
| `Library:LoadConfig(name)` | Загрузить конфиг |
| `Library:ListConfigs()` | Список конфигов |

### Window:CreateTab(name)

Возвращает объект таба со следующими методами:

| Метод | Параметры |
|---|---|
| `:CreateSection(name)` | Заголовок секции |
| `:CreateLabel(text)` | Текстовая метка |
| `:CreateToggle(opts)` | Переключатель |
| `:CreateSlider(opts)` | Слайдер |
| `:CreateButton(opts)` | Кнопка |
| `:CreateDropdown(opts)` | Выпадающий список |
| `:CreateKeybind(opts)` | Биндер клавиш |
| `:CreateTextbox(opts)` | Поле ввода |
| `:CreateColorPicker(opts)` | Цветовой пикер |
| `:CreateConfigPanel()` | Готовая панель конфигов |

### Toggle options
```lua
{
    Name         = "Feature",     -- строка
    CurrentValue = false,         -- bool
    Id           = "unique_id",   -- для сохранения в конфиг
    Callback     = function(v) end
}
```

### Slider options
```lua
{
    Name         = "Speed",
    MinValue     = 0,
    MaxValue     = 100,
    CurrentValue = 50,
    Suffix       = "%",           -- опционально
    Id           = "unique_id",
    Callback     = function(v) end
}
```

### Dropdown options
```lua
{
    Name            = "Target",
    Options         = { "Head", "Torso" },
    CurrentOption   = "Head",
    MultipleOptions = false,       -- true для мультивыбора
    Id              = "unique_id",
    Callback        = function(v) end
}
```

### Keybind options
```lua
{
    Name     = "Aim Key",
    Default  = Enum.KeyCode.C,
    Id       = "unique_id",
    Callback = function(key) end
}
```

---

## Горячие клавиши

| Клавиша | Действие |
|---|---|
| `RightShift` (по умолчанию) | Скрыть / показать UI |

---

## Конфиги

Конфиги сохраняются в папку `BlackWhiteLib/` в файловой системе исполнителя (требует `writefile` / `readfile`).

```lua
Library:SaveConfig("default")   -- сохранить
Library:LoadConfig("default")   -- загрузить
Library:ListConfigs()           -- список всех
```

---

## Структура файлов

```
BlackWhiteLib/
├── Library.lua     -- основная библиотека
└── Example.lua     -- пример использования
```
