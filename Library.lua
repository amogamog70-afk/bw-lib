--[[
    BlackWhite UI Library
    Version: 1.0.0
    Style: Premium Minimal Dark
    
    API Usage:
        local Library = loadstring(game:HttpGet("URL"))()
        local Window = Library:CreateWindow({ Title = "BlackWhite", Size = UDim2.fromOffset(580, 460) })
        local Tab = Window:CreateTab("Legit")
        Tab:CreateToggle({ Name = "Feature", CurrentValue = false, Callback = function(v) end })
]]

local Library = {}
Library.__index = Library

-- ──────────────────────────────────────────────
--  Services
-- ──────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")
local CoreGui         = game:GetService("CoreGui")
local Stats           = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ──────────────────────────────────────────────
--  Theme
-- ──────────────────────────────────────────────
Library.Theme = {
    Background      = Color3.fromHex("0a0a0a"),
    Surface         = Color3.fromHex("111111"),
    SurfaceHover    = Color3.fromHex("1a1a1a"),
    Border          = Color3.fromHex("222222"),
    BorderHover     = Color3.fromHex("444444"),
    Accent          = Color3.fromHex("ffffff"),
    AccentDim       = Color3.fromHex("888888"),
    Text            = Color3.fromHex("f0f0f0"),
    TextDim         = Color3.fromHex("666666"),
    TextDisabled    = Color3.fromHex("333333"),
    Toggle_On       = Color3.fromHex("ffffff"),
    Toggle_Off      = Color3.fromHex("2a2a2a"),
    Notification    = Color3.fromHex("111111"),
    Slider_Fill     = Color3.fromHex("ffffff"),
    Slider_BG       = Color3.fromHex("1e1e1e"),
    TabActive       = Color3.fromHex("ffffff"),
    TabInactive     = Color3.fromHex("2a2a2a"),
    TabActiveText   = Color3.fromHex("0a0a0a"),
    TabInactiveText = Color3.fromHex("888888"),
    WindowTitle     = Color3.fromHex("ffffff"),
    TitleBar        = Color3.fromHex("0d0d0d"),
    CloseBtn        = Color3.fromHex("ff4444"),
    MinBtn          = Color3.fromHex("ffaa00"),
    Watermark       = Color3.fromHex("0d0d0d"),
    WatermarkGlow   = Color3.fromHex("ffffff"),
}

-- ──────────────────────────────────────────────
--  Tween Helper
-- ──────────────────────────────────────────────
local function Tween(obj, props, duration, style, direction)
    duration  = duration  or 0.2
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, direction)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ──────────────────────────────────────────────
--  Create Instance Helper
-- ──────────────────────────────────────────────
local function New(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function Stroke(thickness, color, parent)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Color = color or Library.Theme.Border
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Padding(top, right, bottom, left, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.Parent = parent
    return p
end

local function ListLayout(dir, halign, valign, spacing, parent)
    local l = Instance.new("UIListLayout")
    l.FillDirection      = dir    or Enum.FillDirection.Vertical
    l.HorizontalAlignment= halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment  = valign or Enum.VerticalAlignment.Top
    l.SortOrder          = Enum.SortOrder.LayoutOrder
    l.Padding            = UDim.new(0, spacing or 4)
    l.Parent = parent
    return l
end

-- ──────────────────────────────────────────────
--  Draggable
-- ──────────────────────────────────────────────
local function MakeDraggable(topbar, frame)
    local dragging, dragStart, startPos = false, nil, nil
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ──────────────────────────────────────────────
--  Notification System
-- ──────────────────────────────────────────────
Library._notifHolder = nil
Library._notifQueue  = {}

function Library:_initNotifications(screenGui)
    self._notifHolder = New("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 300, 1, -32),
        Parent = screenGui,
    })
    ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right,
        Enum.VerticalAlignment.Bottom, 8, self._notifHolder)
end

function Library:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Notification"
    local desc     = opts.Content  or ""
    local duration = opts.Duration or 4
    local theme    = self.Theme

    local card = New("Frame", {
        Name = "Notif",
        BackgroundColor3 = theme.Notification,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = self._notifHolder,
    })
    Corner(8, card)
    Stroke(1, theme.Border, card)

    -- Glow stroke
    local glowS = Stroke(1, theme.WatermarkGlow, card)
    glowS.Transparency = 0.7

    local inner = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = card,
    })
    Padding(12, 14, 12, 14, inner)
    ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left,
        Enum.VerticalAlignment.Top, 4, inner)

    New("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inner,
    })
    New("TextLabel", {
        Text = desc,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = theme.TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = inner,
    })

    -- Slide in
    Tween(card, { Size = UDim2.new(1, 0, 0, 62) }, 0.3)

    task.delay(duration, function()
        Tween(card, { Size = UDim2.new(1, 0, 0, 0) }, 0.25).Completed:Connect(function()
            card:Destroy()
        end)
    end)

    return card
end

-- ──────────────────────────────────────────────
--  Watermark
-- ──────────────────────────────────────────────
function Library:_createWatermark(screenGui, execName)
    local theme = self.Theme
    local wm = New("Frame", {
        Name = "Watermark",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = theme.Watermark,
        Position = UDim2.new(0.5, 0, 0, 12),
        Size = UDim2.new(0, 400, 0, 30),
        Parent = screenGui,
    })
    Corner(6, wm)
    Stroke(1, theme.Border, wm)

    local wmPad = Padding(0, 14, 0, 14, wm)
    local wmLayout = ListLayout(Enum.FillDirection.Horizontal,
        Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 18, wm)

    local function WMLabel(text, bold)
        return New("TextLabel", {
            Text = text,
            Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = bold and theme.Text or theme.TextDim,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = wm,
        })
    end

    local lblTitle = WMLabel(execName or "BlackWhite", true)
    local lblSep1  = WMLabel("·", false)
    local lblFPS   = WMLabel("FPS: --", false)
    local lblSep2  = WMLabel("·", false)
    local lblPing  = WMLabel("Ping: --", false)
    local lblSep3  = WMLabel("·", false)
    local lblTime  = WMLabel("00:00", false)
    local lblSep4  = WMLabel("·", false)
    local lblUser  = WMLabel(LocalPlayer.Name, false)

    -- Update loop
    local lastFPS = 0
    local fpsCount = 0
    local fpsTimer = 0
    RunService.RenderStepped:Connect(function(dt)
        fpsTimer += dt
        fpsCount += 1
        if fpsTimer >= 0.5 then
            lastFPS = math.floor(fpsCount / fpsTimer)
            fpsCount = 0
            fpsTimer = 0
        end
        lblFPS.Text  = "FPS: " .. lastFPS
        lblPing.Text = "Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
        local t = os.date("*t")
        lblTime.Text = string.format("%02d:%02d", t.hour, t.min)
    end)

    return wm
end

-- ──────────────────────────────────────────────
--  Config System
-- ──────────────────────────────────────────────
Library._configs   = {}   -- registered elements
Library._configDir = "BlackWhiteLib"

function Library:_regConfig(id, getter, setter)
    self._configs[id] = { get = getter, set = setter }
end

function Library:SaveConfig(name)
    local data = {}
    for id, cfg in pairs(self._configs) do
        local ok, val = pcall(cfg.get)
        if ok then data[id] = val end
    end
    local json = HttpService:JSONEncode(data)
    if writefile then
        if not isfolder(self._configDir) then makefolder(self._configDir) end
        writefile(self._configDir .. "/" .. name .. ".json", json)
        self:Notify({ Title = "Config Saved", Content = name .. ".json saved successfully." })
    end
end

function Library:LoadConfig(name)
    if not readfile then return end
    local path = self._configDir .. "/" .. name .. ".json"
    if not isfile(path) then
        self:Notify({ Title = "Config Error", Content = "Config not found: " .. name })
        return
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok then
        self:Notify({ Title = "Config Error", Content = "Failed to parse config." })
        return
    end
    for id, val in pairs(data) do
        if self._configs[id] then
            pcall(self._configs[id].set, val)
        end
    end
    self:Notify({ Title = "Config Loaded", Content = name .. " loaded successfully." })
end

function Library:ListConfigs()
    if not listfiles then return {} end
    local files = listfiles(self._configDir) or {}
    local names = {}
    for _, f in ipairs(files) do
        local n = f:match("([^/\\]+)%.json$")
        if n then table.insert(names, n) end
    end
    return names
end

-- ──────────────────────────────────────────────
--  Window
-- ──────────────────────────────────────────────
function Library:CreateWindow(opts)
    opts = opts or {}
    local theme    = self.Theme
    local winTitle = opts.Title    or "BlackWhite"
    local winSize  = opts.Size     or UDim2.fromOffset(580, 460)
    local execName = opts.Executor or "Executor"
    local toggleKey= opts.ToggleKey or Enum.KeyCode.RightShift

    -- ScreenGui
    local screenGui = New("ScreenGui", {
        Name = "BlackWhiteLib_" .. winTitle,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })
    -- Try to parent to CoreGui (executor env), fallback to PlayerGui
    local ok = pcall(function() screenGui.Parent = CoreGui end)
    if not ok then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Blur
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game:GetService("Lighting")

    -- Init notifications
    self:_initNotifications(screenGui)

    -- Watermark
    self:_createWatermark(screenGui, execName)

    -- ── Main Frame ──────────────────────────────
    local mainFrame = New("Frame", {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Background,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = winSize,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Corner(10, mainFrame)
    Stroke(1, theme.Border, mainFrame)

    -- Outer glow (shadow via ImageLabel trick)
    local shadow = New("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        ZIndex = mainFrame.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = screenGui,
    })

    -- Intro animation
    mainFrame.Size = UDim2.fromOffset(0, 0)
    mainFrame.BackgroundTransparency = 1
    task.spawn(function()
        Tween(mainFrame, { BackgroundTransparency = 0 }, 0.15)
        Tween(mainFrame, { Size = winSize }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(blur, { Size = 8 }, 0.35)
    end)

    -- ── Title Bar ───────────────────────────────
    local titleBar = New("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = theme.TitleBar,
        Size = UDim2.new(1, 0, 0, 44),
        Parent = mainFrame,
    })
    Corner(10, titleBar)
    -- Hide bottom corners of titlebar
    New("Frame", {
        BackgroundColor3 = theme.TitleBar,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0),
        BorderSizePixel = 0,
        Parent = titleBar,
    })
    Stroke(1, theme.Border, titleBar)

    -- Logo dot
    New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.Accent,
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.new(0, 7, 0, 7),
        Parent = titleBar,
    }):FindFirstChildOfClass("UICorner") or Corner(99, titleBar:FindFirstChild("Frame") or titleBar)

    local dotFrame = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.Accent,
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.new(0, 7, 0, 7),
        Parent = titleBar,
    })
    Corner(99, dotFrame)

    New("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 28, 0.5, 0),
        Size = UDim2.new(0.5, 0, 0, 20),
        Text = winTitle,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = theme.WindowTitle,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    -- Window controls (close / minimize)
    local ctrlHolder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 50, 0, 20),
        Parent = titleBar,
    })
    ListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right,
        Enum.VerticalAlignment.Center, 6, ctrlHolder)

    local function CtrlBtn(color, callback)
        local btn = New("TextButton", {
            BackgroundColor3 = color,
            Size = UDim2.new(0, 12, 0, 12),
            Text = "",
            Parent = ctrlHolder,
        })
        Corner(99, btn)
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function()
            Tween(btn, { Size = UDim2.new(0, 14, 0, 14) }, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { Size = UDim2.new(0, 12, 0, 12) }, 0.1)
        end)
        return btn
    end

    local minimized = false
    local originalSize = winSize

    CtrlBtn(theme.CloseBtn, function()
        Tween(mainFrame, { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }, 0.25)
        Tween(blur, { Size = 0 }, 0.25)
        task.delay(0.3, function() screenGui:Destroy() blur:Destroy() end)
    end)

    CtrlBtn(theme.MinBtn, function()
        minimized = not minimized
        if minimized then
            Tween(mainFrame, { Size = UDim2.fromOffset(winSize.X.Offset, 44) }, 0.3)
        else
            Tween(mainFrame, { Size = winSize }, 0.3)
        end
    end)

    MakeDraggable(titleBar, mainFrame)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    -- ── Tab Bar ─────────────────────────────────
    local tabBar = New("Frame", {
        Name = "TabBar",
        BackgroundColor3 = theme.Surface,
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(1, 0, 0, 38),
        Parent = mainFrame,
    })
    Stroke(1, theme.Border, tabBar)
    Padding(0, 14, 0, 14, tabBar)
    ListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left,
        Enum.VerticalAlignment.Center, 4, tabBar)

    -- Content area
    local contentArea = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 82),
        Size = UDim2.new(1, 0, 1, -82),
        ClipsDescendants = true,
        Parent = mainFrame,
    })

    -- ── Window Object ────────────────────────────
    local Window = {}
    Window._tabs    = {}
    Window._activeTab = nil

    function Window:CreateTab(name)
        local tab = {}
        tab._name   = name
        tab._btn    = nil
        tab._frame  = nil
        tab._elements = {}

        -- Tab button
        local btn = New("TextButton", {
            BackgroundColor3 = theme.TabInactive,
            Size = UDim2.new(0, 0, 0, 26),
            AutoButtonColor = false,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextColor3 = theme.TabInactiveText,
            Parent = tabBar,
        })
        Corner(6, btn)
        Padding(0, 14, 0, 14, btn)
        btn.AutomaticSize = Enum.AutomaticSize.X

        tab._btn = btn

        -- Tab content frame
        local frame = New("ScrollingFrame", {
            Name = "Tab_" .. name,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = contentArea,
        })
        Padding(10, 14, 10, 14, frame)
        ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left,
            Enum.VerticalAlignment.Top, 6, frame)

        tab._frame = frame

        -- Activate tab
        local function activate()
            for _, t in ipairs(Window._tabs) do
                Tween(t._btn, { BackgroundColor3 = theme.TabInactive }, 0.15)
                Tween(t._btn, { TextColor3 = theme.TabInactiveText }, 0.15)
                t._frame.Visible = false
            end
            Tween(btn, { BackgroundColor3 = theme.TabActive }, 0.15)
            Tween(btn, { TextColor3 = theme.TabActiveText }, 0.15)
            frame.Visible = true
            Window._activeTab = tab
        end

        btn.MouseButton1Click:Connect(activate)

        -- Hover
        btn.MouseEnter:Connect(function()
            if Window._activeTab ~= tab then
                Tween(btn, { BackgroundColor3 = theme.SurfaceHover }, 0.1)
            end
        end)
        btn.MouseLeave:Connect(function()
            if Window._activeTab ~= tab then
                Tween(btn, { BackgroundColor3 = theme.TabInactive }, 0.1)
            end
        end)

        table.insert(Window._tabs, tab)
        if #Window._tabs == 1 then activate() end

        -- ── Elements ────────────────────────────────────────────
        local T = self -- keep Library ref
        local lib = Library

        -- Section
        function tab:CreateSection(sectionName)
            local sec = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Parent = frame,
            })
            ListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left,
                Enum.VerticalAlignment.Center, 8, sec)

            New("Frame", {
                BackgroundColor3 = theme.Border,
                Size = UDim2.new(0, 3, 0, 12),
                Parent = sec,
            }):FindFirstChildOfClass("UICorner") or Corner(2, sec)

            local lineFrame = New("Frame", {
                BackgroundColor3 = theme.Border,
                Size = UDim2.new(0, 3, 0, 12),
                Parent = sec,
            })
            Corner(2, lineFrame)

            New("TextLabel", {
                BackgroundTransparency = 1,
                Text = sectionName:upper(),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = theme.TextDim,
                Size = UDim2.new(1, -20, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sec,
            })
        end

        -- Label
        function tab:CreateLabel(text)
            New("TextLabel", {
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = theme.TextDim,
                Size = UDim2.new(1, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })
        end

        -- ── Toggle ──────────────────────────────────────────────
        function tab:CreateToggle(opts)
            opts = opts or {}
            local name     = opts.Name         or "Toggle"
            local value    = opts.CurrentValue or false
            local callback = opts.Callback     or function() end
            local id       = opts.Id           or (name .. tostring(math.random(1,9999)))

            local row = New("Frame", {
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 38),
                Parent = frame,
            })
            Corner(8, row)
            Stroke(1, theme.Border, row)
            Padding(0, 12, 0, 12, row)

            New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, -52, 1, 0),
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local track = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = value and theme.Toggle_On or theme.Toggle_Off,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 38, 0, 20),
                Parent = row,
            })
            Corner(99, track)
            Stroke(1, theme.Border, track)

            local knob = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = value and theme.Background or theme.TextDim,
                Position = UDim2.new(0, value and 20 or 2, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = track,
            })
            Corner(99, knob)

            local function set(v)
                value = v
                Tween(track, { BackgroundColor3 = v and theme.Toggle_On or theme.Toggle_Off }, 0.2)
                Tween(knob,  { Position = UDim2.new(0, v and 20 or 2, 0.5, 0) }, 0.2)
                Tween(knob,  { BackgroundColor3 = v and theme.Background or theme.TextDim }, 0.2)
                pcall(callback, v)
            end

            local btn = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = row.ZIndex + 2,
                Parent = row,
            })
            btn.MouseButton1Click:Connect(function() set(not value) end)

            -- Hover
            btn.MouseEnter:Connect(function()
                Tween(row, { BackgroundColor3 = theme.SurfaceHover }, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                Tween(row, { BackgroundColor3 = theme.Surface }, 0.1)
            end)

            lib:_regConfig(id, function() return value end, function(v) set(v) end)

            return { SetValue = set, GetValue = function() return value end }
        end

        -- ── Slider ──────────────────────────────────────────────
        function tab:CreateSlider(opts)
            opts = opts or {}
            local name     = opts.Name     or "Slider"
            local min      = opts.MinValue or 0
            local max      = opts.MaxValue or 100
            local value    = opts.CurrentValue or min
            local suffix   = opts.Suffix   or ""
            local callback = opts.Callback or function() end
            local id       = opts.Id       or (name .. tostring(math.random(1,9999)))

            value = math.clamp(value, min, max)

            local row = New("Frame", {
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = frame,
            })
            Corner(8, row)
            Stroke(1, theme.Border, row)
            Padding(6, 12, 6, 12, row)
            ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left,
                Enum.VerticalAlignment.Center, 6, row)

            -- Top row: name + value
            local topRow = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Parent = row,
            })
            New("TextLabel", {
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = theme.Text,
                Size = UDim2.new(0.7, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = topRow,
            })
            local valLabel = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Text = tostring(value) .. suffix,
                Font = Enum.Font.GothamSemibold,
                TextSize = 12,
                TextColor3 = theme.AccentDim,
                Size = UDim2.new(0.3, 0, 1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = topRow,
            })

            -- Track
            local trackBG = New("Frame", {
                BackgroundColor3 = theme.Slider_BG,
                Size = UDim2.new(1, 0, 0, 6),
                Parent = row,
            })
            Corner(99, trackBG)

            local fillPct = (value - min) / (max - min)
            local trackFill = New("Frame", {
                BackgroundColor3 = theme.Slider_Fill,
                Size = UDim2.new(fillPct, 0, 1, 0),
                Parent = trackBG,
            })
            Corner(99, trackFill)

            local function updateSlider(v)
                v = math.clamp(math.floor(v), min, max)
                value = v
                local pct = (v - min) / (max - min)
                Tween(trackFill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.08)
                valLabel.Text = tostring(v) .. suffix
                pcall(callback, v)
            end

            local dragging = false
            local btn = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = trackBG.ZIndex + 2,
                Text = "",
                Parent = trackBG,
            })
            btn.MouseButton1Down:Connect(function()
                dragging = true
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local relX = math.clamp((i.Position.X - trackBG.AbsolutePosition.X) / trackBG.AbsoluteSize.X, 0, 1)
                    updateSlider(min + (max - min) * relX)
                end
            end)

            -- Hover
            row.MouseEnter:Connect(function()
                Tween(row, { BackgroundColor3 = theme.SurfaceHover }, 0.1)
            end)
            row.MouseLeave:Connect(function()
                Tween(row, { BackgroundColor3 = theme.Surface }, 0.1)
            end)

            lib:_regConfig(id, function() return value end, function(v) updateSlider(v) end)

            return { SetValue = updateSlider, GetValue = function() return value end }
        end

        -- ── Button ──────────────────────────────────────────────
        function tab:CreateButton(opts)
            opts = opts or {}
            local name     = opts.Name     or "Button"
            local callback = opts.Callback or function() end

            local btn = New("TextButton", {
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 38),
                AutoButtonColor = false,
                Text = "",
                Parent = frame,
            })
            Corner(8, btn)
            Stroke(1, theme.Border, btn)

            New("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                Text = name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 12,
                TextColor3 = theme.Text,
                Parent = btn,
            })

            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundColor3 = theme.SurfaceHover }, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = theme.Surface }, 0.1)
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(btn, { BackgroundColor3 = theme.BorderHover }, 0.08)
            end)
            btn.MouseButton1Up:Connect(function()
                Tween(btn, { BackgroundColor3 = theme.SurfaceHover }, 0.08)
                pcall(callback)
            end)

            return btn
        end

        -- ── Dropdown ────────────────────────────────────────────
        function tab:CreateDropdown(opts)
            opts = opts or {}
            local name     = opts.Name    or "Dropdown"
            local items    = opts.Options or {}
            local value    = opts.CurrentOption or (items[1] or "")
            local callback = opts.Callback or function() end
            local id       = opts.Id      or (name .. tostring(math.random(1,9999)))
            local multi    = opts.MultipleOptions or false

            local selected = multi and {} or value
            if multi then
                if type(opts.CurrentOption) == "table" then
                    selected = opts.CurrentOption
                end
            end

            local open = false

            local wrapper = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
                ClipsDescendants = false,
                Parent = frame,
            })

            local header = New("Frame", {
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 38),
                Parent = wrapper,
            })
            Corner(8, header)
            Stroke(1, theme.Border, header)
            Padding(0, 12, 0, 12, header)

            New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })

            local valLabel = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 0.5, 0),
                Size = UDim2.new(0.35, 0, 1, 0),
                Text = multi and "..." or tostring(value),
                Font = Enum.Font.GothamSemibold,
                TextSize = 11,
                TextColor3 = theme.AccentDim,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = header,
            })

            -- Arrow
            local arrow = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Text = "▾",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = theme.TextDim,
                Parent = header,
            })

            -- Dropdown list
            local dropdown = New("Frame", {
                BackgroundColor3 = theme.Surface,
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.new(1, 0, 0, 0),
                ClipsDescendants = true,
                ZIndex = 10,
                Parent = wrapper,
            })
            Corner(8, dropdown)
            Stroke(1, theme.Border, dropdown)

            local ddScroll = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = theme.Border,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = dropdown,
            })
            Padding(4, 8, 4, 8, ddScroll)
            ListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left,
                Enum.VerticalAlignment.Top, 2, ddScroll)

            local function refreshLabel()
                if multi then
                    valLabel.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                else
                    valLabel.Text = tostring(selected)
                end
            end

            local function buildItems()
                for _, c in ipairs(ddScroll:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, item in ipairs(items) do
                    local isActive = multi
                        and (function() for _, s in ipairs(selected) do if s == item then return true end end return false end)()
                        or selected == item

                    local itemBtn = New("TextButton", {
                        BackgroundColor3 = isActive and theme.SurfaceHover or theme.Surface,
                        Size = UDim2.new(1, 0, 0, 28),
                        AutoButtonColor = false,
                        Text = item,
                        Font = isActive and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                        TextSize = 12,
                        TextColor3 = isActive and theme.Text or theme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = ddScroll,
                    })
                    Corner(6, itemBtn)
                    Padding(0, 8, 0, 8, itemBtn)

                    itemBtn.MouseEnter:Connect(function()
                        Tween(itemBtn, { BackgroundColor3 = theme.SurfaceHover }, 0.08)
                    end)
                    itemBtn.MouseLeave:Connect(function()
                        if not (multi and (function() for _, s in ipairs(selected) do if s == item then return true end end return false end)()) and selected ~= item then
                            Tween(itemBtn, { BackgroundColor3 = theme.Surface }, 0.08)
                        end
                    end)
                    itemBtn.MouseButton1Click:Connect(function()
                        if multi then
                            local found = false
                            for i, s in ipairs(selected) do
                                if s == item then table.remove(selected, i) found = true break end
                            end
                            if not found then table.insert(selected, item) end
                        else
                            selected = item
                        end
                        refreshLabel()
                        buildItems()
                        pcall(callback, selected)
                    end)
                end
            end

            buildItems()

            local function toggleDD()
                open = not open
                local targetH = open and math.min(#items * 32 + 12, 160) or 0
                Tween(dropdown, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
                Tween(wrapper, { Size = UDim2.new(1, 0, 0, 38 + (open and targetH + 4 or 0)) }, 0.2)
                Tween(arrow, { Rotation = open and 180 or 0 }, 0.2)
            end

            local hBtn = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = header,
            })
            hBtn.MouseButton1Click:Connect(toggleDD)
            hBtn.MouseEnter:Connect(function()
                Tween(header, { BackgroundColor3 = theme.SurfaceHover }, 0.1)
            end)
            hBtn.MouseLeave:Connect(function()
                Tween(header, { BackgroundColor3 = theme.Surface }, 0.1)
            end)

            lib:_regConfig(id, function() return selected end,
                function(v) selected = v refreshLabel() buildItems() end)

            return {
                SetOptions = function(newItems)
                    items = newItems
                    buildItems()
                end,
                GetValue = function() return selected end,
            }
        end

        -- ── Keybind ─────────────────────────────────────────────
        function tab:CreateKeybind(opts)
            opts = opts or {}
            local name     = opts.Name    or "Keybind"
            local default  = opts.Default or Enum.KeyCode.Unknown
            local callback = opts.Callback or function() end
            local id       = opts.Id      or (name .. tostring(math.random(1,9999)))

            local currentKey = default
            local listening  = false

            local row = New("Frame", {
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 38),
                Parent = frame,
            })
            Corner(8, row)
            Stroke(1, theme.Border, row)
            Padding(0, 12, 0, 12, row)

            New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0.6, 1, 1, 0),
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local keyBadge = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = theme.SurfaceHover,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 70, 0, 24),
                AutoButtonColor = false,
                Text = currentKey.Name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 11,
                TextColor3 = theme.AccentDim,
                Parent = row,
            })
            Corner(6, keyBadge)
            Stroke(1, theme.Border, keyBadge)

            keyBadge.MouseButton1Click:Connect(function()
                listening = true
                keyBadge.Text = "..."
                Tween(keyBadge, { TextColor3 = theme.Text }, 0.1)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    currentKey = input.KeyCode
                    keyBadge.Text = input.KeyCode.Name
                    Tween(keyBadge, { TextColor3 = theme.AccentDim }, 0.1)
                    pcall(callback, currentKey)
                elseif not listening and input.KeyCode == currentKey then
                    pcall(callback, currentKey)
                end
            end)

            lib:_regConfig(id,
                function() return currentKey.Name end,
                function(v)
                    local ok, kc = pcall(function() return Enum.KeyCode[v] end)
                    if ok and kc then currentKey = kc keyBadge.Text = v end
                end)

            return { GetKey = function() return currentKey end }
        end

        -- ── Textbox ─────────────────────────────────────────────
        function tab:CreateTextbox(opts)
            opts = opts or {}
            local name     = opts.Name        or "Textbox"
            local placeholder = opts.PlaceholderText or "Type here..."
            local value    = opts.CurrentValue or ""
            local callback = opts.Callback    or function() end

            local row = New("Frame", {
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 38),
                Parent = frame,
            })
            Corner(8, row)
            local rowStroke = Stroke(1, theme.Border, row)
            Padding(0, 12, 0, 12, row)

            New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local box = New("TextBox", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = theme.SurfaceHover,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0.55, 0, 0, 26),
                PlaceholderText = placeholder,
                PlaceholderColor3 = theme.TextDim,
                Text = value,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = theme.Text,
                ClearTextOnFocus = false,
                Parent = row,
            })
            Corner(6, box)
            Padding(0, 8, 0, 8, box)

            box.Focused:Connect(function()
                Tween(rowStroke, { Color = theme.BorderHover }, 0.15)
            end)
            box.FocusLost:Connect(function()
                Tween(rowStroke, { Color = theme.Border }, 0.15)
                pcall(callback, box.Text)
            end)

            return { GetValue = function() return box.Text end }
        end

        -- ── ColorPicker ─────────────────────────────────────────
        function tab:CreateColorPicker(opts)
            opts = opts or {}
            local name     = opts.Name         or "Color"
            local value    = opts.CurrentColor or Color3.new(1,1,1)
            local callback = opts.Callback     or function() end
            local id       = opts.Id           or (name .. tostring(math.random(1,9999)))

            local row = New("Frame", {
                BackgroundColor3 = theme.Surface,
                Size = UDim2.new(1, 0, 0, 38),
                Parent = frame,
            })
            Corner(8, row)
            Stroke(1, theme.Border, row)
            Padding(0, 12, 0, 12, row)

            New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0.7, 0, 1, 0),
                Text = name,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })

            local preview = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = value,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 26, 0, 26),
                Parent = row,
            })
            Corner(6, preview)
            Stroke(1, theme.Border, preview)

            -- Note: Full HSV picker would require a full sub-window;
            -- this provides the API surface and preview swatch.
            local function set(c)
                value = c
                preview.BackgroundColor3 = c
                pcall(callback, c)
            end

            lib:_regConfig(id,
                function() return { value.R, value.G, value.B } end,
                function(v) set(Color3.new(v[1], v[2], v[3])) end)

            return { SetColor = set, GetColor = function() return value end }
        end

        -- ── Config Panel ─────────────────────────────────────────
        function tab:CreateConfigPanel()
            tab:CreateSection("Config")

            local nameBox = tab:CreateTextbox({
                Name = "Config Name",
                PlaceholderText = "my_config",
            })

            tab:CreateButton({ Name = "💾  Save Config", Callback = function()
                local n = nameBox.GetValue()
                if n and n ~= "" then lib:SaveConfig(n)
                else lib:Notify({ Title = "Config", Content = "Enter a config name first." }) end
            end})

            tab:CreateButton({ Name = "📂  Load Config", Callback = function()
                local n = nameBox.GetValue()
                if n and n ~= "" then lib:LoadConfig(n)
                else lib:Notify({ Title = "Config", Content = "Enter a config name first." }) end
            end})

            tab:CreateButton({ Name = "🔄  List Configs", Callback = function()
                local configs = lib:ListConfigs()
                lib:Notify({
                    Title = "Configs",
                    Content = #configs > 0 and table.concat(configs, ", ") or "No configs found.",
                    Duration = 5,
                })
            end})
        end

        return tab
    end

    return Window
end

-- ──────────────────────────────────────────────
--  Return Library
-- ──────────────────────────────────────────────
return Library
