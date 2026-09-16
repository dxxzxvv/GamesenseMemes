-- LocalScript в StarterPlayerScripts
-- Gamesense ESP v6.3: оповещения о редких + статистика сессии

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

print("[Gamesense] ESP v6.3 загружен")

-- ==================== ТЕМЫ ====================
local Themes = {
    {name="Gamesense", bg=Color3.fromRGB(18,18,20),   accent=Color3.fromRGB(0,200,160),  text=Color3.fromRGB(230,230,230)},
    {name="Sakura",    bg=Color3.fromRGB(40,20,30),   accent=Color3.fromRGB(255,150,200), text=Color3.fromRGB(255,230,240)},
    {name="Midnight",  bg=Color3.fromRGB(10,15,35),   accent=Color3.fromRGB(120,100,255), text=Color3.fromRGB(220,220,255)},
    {name="Neon",      bg=Color3.fromRGB(15,5,30),    accent=Color3.fromRGB(180,60,255),  text=Color3.fromRGB(0,255,220)},
    {name="Dracula",   bg=Color3.fromRGB(40,42,54),   accent=Color3.fromRGB(189,147,249), text=Color3.fromRGB(248,248,242)},
    {name="Ocean",     bg=Color3.fromRGB(10,25,40),   accent=Color3.fromRGB(0,180,255),   text=Color3.fromRGB(220,240,255)},
    {name="Sunset",    bg=Color3.fromRGB(35,15,25),   accent=Color3.fromRGB(255,140,60),  text=Color3.fromRGB(255,230,200)},
    {name="Matrix",    bg=Color3.fromRGB(5,15,5),     accent=Color3.fromRGB(0,255,80),    text=Color3.fromRGB(200,255,200)},
    {name="Cyberpunk", bg=Color3.fromRGB(15,10,25),   accent=Color3.fromRGB(255,220,0),   text=Color3.fromRGB(255,255,255)},
    {name="Blood",     bg=Color3.fromRGB(25,5,5),     accent=Color3.fromRGB(220,30,30),   text=Color3.fromRGB(255,220,220)},
    {name="Ice",       bg=Color3.fromRGB(20,30,45),   accent=Color3.fromRGB(150,220,255), text=Color3.fromRGB(240,250,255)},
    {name="Gold",      bg=Color3.fromRGB(25,20,10),   accent=Color3.fromRGB(255,200,50),  text=Color3.fromRGB(255,240,200)},
    {name="Purple",    bg=Color3.fromRGB(25,15,40),   accent=Color3.fromRGB(200,120,255), text=Color3.fromRGB(240,220,255)},
    {name="Forest",    bg=Color3.fromRGB(15,25,15),   accent=Color3.fromRGB(120,220,100), text=Color3.fromRGB(220,255,220)},
    {name="Royal",     bg=Color3.fromRGB(20,15,35),   accent=Color3.fromRGB(220,180,80),  text=Color3.fromRGB(255,240,220)},
}
local themeIdx = 1
local currentTheme = Themes[1]

-- ==================== РЕДКОСТИ ====================
local Rarities = {
    {name = "Divine",    color = Color3.fromRGB(255, 240, 100)},
    {name = "Eternal",   color = Color3.fromRGB(100, 255, 255)},
    {name = "Secret",    color = Color3.fromRGB(180, 0, 0)},
    {name = "Cosmic",    color = Color3.fromRGB(255, 100, 255)},
    {name = "Mythic",    color = Color3.fromRGB(255, 50, 50)},
    {name = "Legendary", color = Color3.fromRGB(255, 215, 0)},
    {name = "Epic",      color = Color3.fromRGB(180, 80, 255)},
    {name = "Rare",      color = Color3.fromRGB(80, 150, 255)},
    {name = "Uncommon",  color = Color3.fromRGB(80, 220, 80)},
    {name = "Common",    color = Color3.fromRGB(180, 180, 180)},
}

-- Быстрый доступ к цвету по имени
local RarityColor = {}
for _, r in ipairs(Rarities) do RarityColor[r.name] = r.color end

-- ==================== ОПОВЕЩЕНИЕ: КАКИЕ РЕДКОСТИ СЧИТАТЬ РЕДКИМИ ====================
local AlertRarities = {
    Divine = true, Eternal = true, Secret = true, Cosmic = true, Mythic = true, Legendary = true,
}
local AlertDistance = 250  -- studs, максимальная дистанция для оповещения

-- ==================== БАЗА ЯИЦ ====================
local EggDatabase = {
    ["chicken"]="Common", ["dog"]="Common", ["bird"]="Uncommon",
    ["burrowing owl"]="Rare", ["raccoon"]="Rare", ["fox"]="Epic",
    ["bear"]="Epic", ["brr brr patapim"]="Legendary",
    ["frog"]="Common", ["duckling"]="Common", ["catfish"]="Uncommon",
    ["turtle"]="Rare", ["trulimero trulicina"]="Epic", ["swan"]="Epic",
    ["axolotl"]="Legendary", ["leviathan"]="Cosmic",
    ["jerboa"]="Common", ["fennec"]="Uncommon", ["camel"]="Rare",
    ["tob tobi tob tob"]="Epic", ["snake"]="Legendary",
    ["sand spider"]="Mythic", ["scorpion"]="Mythic", ["royal sphinx"]="Cosmic",
    ["chimpanzee"]="Rare", ["toucan"]="Rare", ["crocodile"]="Epic",
    ["gorilla"]="Legendary", ["orangutini ananassini"]="Legendary",
    ["spider"]="Mythic", ["tiger"]="Mythic", ["king snake"]="Secret",
    ["penguin"]="Rare", ["walrus"]="Epic", ["polar bear"]="Legendary",
    ["sabertooth tiger"]="Mythic", ["mammoth"]="Mythic",
    ["king mammoth"]="Cosmic", ["yeti"]="Secret", ["ice dragon"]="Eternal",
    ["lava gecko"]="Rare", ["lava frog"]="Epic", ["flaming bull"]="Legendary",
    ["lava iguana"]="Legendary", ["chillin chilli"]="Mythic",
    ["cerberus"]="Secret", ["phoenix"]="Eternal", ["lava dragon"]="Eternal",
    ["parrotfish"]="Rare", ["swordfish"]="Epic", ["shark"]="Legendary",
    ["orca"]="Mythic", ["whale shark"]="Cosmic", ["beluga whale"]="Cosmic",
    ["kraken"]="Secret", ["el maja"]="Eternal",
    ["dodo"]="Rare", ["pterodactyl"]="Legendary", ["ankylosaurus"]="Mythic",
    ["triceratops"]="Cosmic", ["bronto"]="Cosmic",
    ["t-rex"]="Secret", ["trex"]="Secret", ["tralaledon"]="Secret",
    ["mosasaurus"]="Eternal",
    ["centapede"]="Epic", ["cosmic gecko"]="Legendary",
    ["cosmic gorilla"]="Mythic", ["la vacca saturno saturnita"]="Cosmic",
    ["cosmic skeleton boss"]="Secret", ["cosmic dragon"]="Secret",
    ["eternal lunar dragon"]="Eternal", ["unicorn"]="Divine",
    ["crane"]="Epic", ["salamander"]="Legendary", ["red panda"]="Mythic",
    ["snowy owl"]="Cosmic", ["koi"]="Cosmic", ["stag"]="Secret",
    ["kitsune"]="Divine",
    ["gorilla king"]="Legendary", ["nightflame"]="Divine",
    ["riftborn"]="Legendary", ["riftbeasts"]="Legendary",
    ["shattered rift"]="Cosmic", ["void dragon"]="Eternal",
    ["tung tung sahur"]="Rare", ["bananita dolphinita"]="Epic",
    ["belula beluga"]="Mythic", ["mangolini parrochini"]="Cosmic",
    ["bomboclat crocolat"]="Secret", ["strawberry elephant"]="Eternal",
    ["mecha dreadscale"]="Eternal",
}

-- ==================== ЧЁРНЫЙ СПИСОК ====================
local Blacklist = {
    "eggfitbounds","hitbox","collision","bounds","trigger",
    "eggsign","eggpoint","eggspawn","capturetheeggspawn",
    "eggmarker","eggzone","eggpad","eggbase","eggdisplay",
    "eggstand","eggholder","eggspot","eggnest","eggtimer",
    "egggui","interact","proximity","prompt","detector",
    "zone","region","area","spawner",
}
local function isBlacklisted(name)
    local l = name:lower()
    for _, b in ipairs(Blacklist) do
        if l:find(b, 1, true) then return true end
    end
    return false
end

-- ==================== ОПРЕДЕЛЕНИЕ РЕДКОСТИ ====================
local function detectRarity(eggModel)
    local names = { eggModel.Name }
    if eggModel.Parent then table.insert(names, eggModel.Parent.Name) end
    for _, child in ipairs(eggModel:GetDescendants()) do
        table.insert(names, child.Name)
        if #names > 50 then break end
    end

    for _, n in ipairs(names) do
        local l = n:lower()
        l = l:gsub("egg", ""):gsub("rbx", ""):gsub("[_%-%.]", " "):gsub("%s+", " ")
        l = l:gsub("^%s+", ""):gsub("%s+$", "")

        for _, r in ipairs(Rarities) do
            if l:find(r.name:lower(), 1, true) then return r.name, r.color end
        end
        for key, rar in pairs(EggDatabase) do
            if l:find(key, 1, true) then
                return rar, RarityColor[rar]
            end
        end
    end

    local attr = eggModel:GetAttribute("Rarity") or eggModel:GetAttribute("rarity")
        or eggModel:GetAttribute("RarityName") or eggModel:GetAttribute("EggRarity")
    if attr and typeof(attr) == "string" then
        for _, r in ipairs(Rarities) do
            if attr:lower() == r.name:lower() then return r.name, r.color end
        end
    end

    for _, child in ipairs(eggModel:GetDescendants()) do
        local a = child:GetAttribute("Rarity") or child:GetAttribute("rarity")
        if a and typeof(a) == "string" then
            for _, r in ipairs(Rarities) do
                if a:lower() == r.name:lower() then return r.name, r.color end
            end
        end
    end

    local part = nil
    if eggModel:IsA("BasePart") then part = eggModel
    elseif eggModel.PrimaryPart then part = eggModel.PrimaryPart
    else
        for _, c in ipairs(eggModel:GetChildren()) do
            if c:IsA("BasePart") then part = c break end
        end
    end
    if part then
        local c = part.Color
        if c.R > 0.9 and c.G > 0.9 and c.B > 0.9 then return "Divine", RarityColor.Divine end
        if c.R > 0.8 and c.G < 0.5 and c.B < 0.5 then return "Mythic", RarityColor.Mythic end
        if c.R > 0.9 and c.G > 0.7 and c.B < 0.4 then return "Legendary", RarityColor.Legendary end
        if c.R < 0.4 and c.G < 0.5 and c.B > 0.8 then return "Rare", RarityColor.Rare end
        if c.R < 0.4 and c.G > 0.7 and c.B < 0.5 then return "Uncommon", RarityColor.Uncommon end
    end
    return "Common", RarityColor.Common
end

-- ==================== ФИЛЬТР ====================
local function isEggCandidate(obj)
    if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end
    if isBlacklisted(obj.Name) then return false end
    if obj.Name:lower():find("egg", 1, true) then return true end
    local p = obj.Parent
    local d = 0
    while p and d < 3 do
        if p.Name:lower():find("egg", 1, true) then return true end
        p = p.Parent; d = d + 1
    end
    return false
end

local function isRootEgg(obj)
    if not isEggCandidate(obj) then return false end
    local p = obj.Parent
    if p and (p:IsA("Model") or p:IsA("BasePart")) then
        if isEggCandidate(p) and not isBlacklisted(p.Name) then return false end
    end
    return true
end

local function getEggPart(egg)
    if egg:IsA("BasePart") then return egg end
    if egg.PrimaryPart then return egg.PrimaryPart end
    for _, c in ipairs(egg:GetChildren()) do
        if c:IsA("BasePart") then return c end
    end
    for _, c in ipairs(egg:GetDescendants()) do
        if c:IsA("BasePart") then return c end
    end
end

-- ==================== ЗВУК ====================
local function playSound(id, pitch, vol)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.PlaybackSpeed = pitch or 1
        s.Volume = vol or 0.5
        s.Parent = SoundService
        s:Play()
        game:GetService("Debris"):AddItem(s, 2)
    end)
end

-- ==================== СТАТИСТИКА СЕССИИ ====================
local Stats = {
    startTime = os.time(),
    found = {},              -- {rarityName -> count} яиц замечено
    collected = {},          -- {rarityName -> count} собрано (исчезло рядом с игроком)
    totalCollected = 0,
    totalFound = 0,
    lastCollectedName = "-",
    lastCollectedRarity = "-",
}
for _, r in ipairs(Rarities) do
    Stats.found[r.name] = 0
    Stats.collected[r.name] = 0
end

-- Отслеживание исчезнувших яиц (для подсчёта собранных)
local eggLastPositions = {}   -- {egg -> Vector3}
local eggRarityCache = {}     -- {egg -> rarityName}

local function formatTime(sec)
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%d:%02d", m, s)
end

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "Gamesense"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== УВЕДОМЛЕНИЯ ====================
local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 280, 1, 0)
notifContainer.Position = UDim2.new(1, -300, 0, 100)
notifContainer.BackgroundTransparency = 1
notifContainer.ZIndex = 50
notifContainer.Parent = gui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Padding = UDim.new(0, 6)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.Parent = notifContainer

local notifId = 0
local function notify(text, color)
    color = color or currentTheme.accent
    notifId = notifId + 1

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.LayoutOrder = notifId
    frame.ZIndex = 51
    frame.Parent = notifContainer

    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = frame
    local fcStroke = Instance.new("UIStroke")
    fcStroke.Color = color; fcStroke.Thickness = 1.5; fcStroke.Transparency = 1
    fcStroke.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.ZIndex = 52
    bar.Parent = frame
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = bar

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 52
    lbl.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 0.15}):Play()
    TweenService:Create(fcStroke, TweenInfo.new(0.25), {Transparency = 0.4}):Play()
    TweenService:Create(lbl, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
    TweenService:Create(bar, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()

    task.delay(2.5, function()
        TweenService:Create(frame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        TweenService:Create(fcStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(bar, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        if frame and frame.Parent then frame:Destroy() end
    end)
end

-- ==================== ГЛАВНОЕ ОКНО ====================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 620)
main.Position = UDim2.new(0, 20, 0, 40)
main.BackgroundColor3 = currentTheme.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 10); mc.Parent = main
local stroke = Instance.new("UIStroke")
stroke.Color = currentTheme.accent
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Gamesense ESP"
title.TextColor3 = currentTheme.accent
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = main

-- ===== Секции =====
local toggleButtons = {}
local sectionLabels = {}

local function makeSection(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = "— " .. text .. " —"
    lbl.TextColor3 = currentTheme.accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = main
    table.insert(sectionLabels, lbl)
end

local function makeToggle(text, y, defaultOn)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 26)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = currentTheme.accent
    btn.Text = text .. ": " .. (defaultOn and "ON" or "OFF")
    btn.TextColor3 = currentTheme.bg
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = main

    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn

    local on = defaultOn
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = text .. ": " .. (on and "ON" or "OFF")
        notify(text .. ": " .. (on and "ВКЛ" or "ВЫКЛ"),
            on and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(255, 120, 120))
        print("[Gamesense]", text, on and "ON" or "OFF")
    end)
    table.insert(toggleButtons, btn)
    return function() return on end
end

makeSection("Игроки", 46)
local tPlayerESP = makeToggle("Подсветка игроков", 66, true)
local tPlayerName = makeToggle("Имя игрока", 96, true)
local tPlayerDist = makeToggle("Дистанция игрока", 126, true)

makeSection("Яйца", 158)
local tEggESP = makeToggle("Подсветка яиц", 178, true)
local tEggRarity = makeToggle("Редкость", 208, true)

-- ===== ОПОВЕЩЕНИЕ О РЕДКИХ (№3) =====
makeSection("🔔 Оповещение о редких", 240)
local tAlert = makeToggle("Оповещение", 260, true)
local tAlertSound = makeToggle("Звук оповещения", 290, true)

-- Инфо о настройках оповещения
local alertInfo = Instance.new("TextLabel")
alertInfo.Size = UDim2.new(1, -20, 0, 16)
alertInfo.Position = UDim2.new(0, 10, 0, 320)
alertInfo.BackgroundTransparency = 1
alertInfo.Text = "Дистанция: " .. AlertDistance .. " | Divine+Eternal+Secret+Cosmic+Mythic+Legendary"
alertInfo.TextColor3 = currentTheme.text
alertInfo.TextTransparency = 0.5
alertInfo.Font = Enum.Font.Gotham
alertInfo.TextSize = 9
alertInfo.TextXAlignment = Enum.TextXAlignment.Left
alertInfo.Parent = main

-- ===== СТАТИСТИКА СЕССИИ (№6) =====
makeSection("📊 Статистика сессии", 344)

local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -20, 0, 120)
statsFrame.Position = UDim2.new(0, 10, 0, 366)
statsFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
statsFrame.BorderSizePixel = 0
statsFrame.Parent = main

local sfc = Instance.new("UICorner"); sfc.CornerRadius = UDim.new(0, 6); sfc.Parent = statsFrame

local statsTimeLbl = Instance.new("TextLabel")
statsTimeLbl.Size = UDim2.new(1, -10, 0, 16)
statsTimeLbl.Position = UDim2.new(0, 5, 0, 4)
statsTimeLbl.BackgroundTransparency = 1
statsTimeLbl.Text = "Время: 0:00"
statsTimeLbl.TextColor3 = currentTheme.text
statsTimeLbl.Font = Enum.Font.GothamBold
statsTimeLbl.TextSize = 11
statsTimeLbl.TextXAlignment = Enum.TextXAlignment.Left
statsTimeLbl.Parent = statsFrame

local statsTotalLbl = Instance.new("TextLabel")
statsTotalLbl.Size = UDim2.new(1, -10, 0, 16)
statsTotalLbl.Position = UDim2.new(0, 5, 0, 20)
statsTotalLbl.BackgroundTransparency = 1
statsTotalLbl.Text = "Собрано: 0 | Найдено: 0"
statsTotalLbl.TextColor3 = currentTheme.accent
statsTotalLbl.Font = Enum.Font.GothamBold
statsTotalLbl.TextSize = 11
statsTotalLbl.TextXAlignment = Enum.TextXAlignment.Left
statsTotalLbl.Parent = statsFrame

-- Строки для каждой редкости (только для collected)
local statsRows = {}
local yOff = 38
for _, r in ipairs(Rarities) do
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(0, 155, 0, 12)
    row.Position = UDim2.new(0, 5, 0, yOff)
    row.BackgroundTransparency = 1
    row.Text = r.name .. ": 0"
    row.TextColor3 = r.color
    row.Font = Enum.Font.Gotham
    row.TextSize = 10
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = statsFrame
    statsRows[r.name] = row
    yOff = yOff + 8
end

local lastCollectedLbl = Instance.new("TextLabel")
lastCollectedLbl.Size = UDim2.new(1, -10, 0, 14)
lastCollectedLbl.Position = UDim2.new(0, 5, 0, 104)
lastCollectedLbl.BackgroundTransparency = 1
lastCollectedLbl.Text = "Последний: -"
lastCollectedLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
lastCollectedLbl.Font = Enum.Font.Gotham
lastCollectedLbl.TextSize = 10
lastCollectedLbl.TextXAlignment = Enum.TextXAlignment.Left
lastCollectedLbl.Parent = statsFrame

-- Кнопка сброса статистики
local resetStatsBtn = Instance.new("TextButton")
resetStat
