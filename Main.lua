
--[[
    GULOSÃO HUB V8
    HARD AIMBOT + ESP + SMOOTH 0-10

    RightShift = Mostrar/ocultar menu
    Botão direito = Travar mira
    G = Ativar/desativar Aimbot

    Smooth 0  = Sem ajuste de câmera
    Smooth 10 = Travamento instantâneo
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- Remover versão anterior
if _G.GulosaoCleanup then
    pcall(_G.GulosaoCleanup)
end

local cfg = {
    AimEnabled = true,
    AutoAim = true,
    HeadOnly = true,
    TeamCheck = true,
    WallCheck = true,
    FOV = 600,
    StickyFOV = 1000,
    Smoothness = 10,

    ESPEnabled = false,
    ESPNames = true,
    ESPDistance = true,
    ESPHighlight = true,
    ESPTeamCheck = true
}

local PURPLE = Color3.fromRGB(150, 75, 255)
local DARK = Color3.fromRGB(15, 15, 22)
local PANEL = Color3.fromRGB(29, 26, 41)
local BUTTON = Color3.fromRGB(48, 39, 67)

local active = true
local holding = false
local target = nil
local connections = {}
local espObjects = {}

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

-- INTERFACE

local gui = Instance.new("ScreenGui")
gui.Name = "GulosaoHubV8"
gui.ResetOnSpawn = false
gui.Parent = PG

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(380, 440)
main.Position = UDim2.new(0.5, -190, 0.5, -220)
main.BackgroundColor3 = DARK
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
round(main, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = PURPLE
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 45)
title.Position = UDim2.fromOffset(15, 5)
title.BackgroundTransparency = 1
title.Text = "GULOSÃO HUB V8"
title.TextColor3 = PURPLE
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -43, 0, 12)
close.BackgroundColor3 = PURPLE
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.Text = "X"
close.Parent = main
round(close, 7)

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -20, 0, 40)
tabs.Position = UDim2.fromOffset(10, 55)
tabs.BackgroundTransparency = 1
tabs.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 8)
tabLayout.Parent = tabs

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -110)
content.Position = UDim2.fromOffset(10, 100)
content.BackgroundColor3 = PANEL
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = PURPLE
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new()
content.Parent = main
round(content, 8)

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.Parent = content

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.Parent = content

local function makeButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 38)
    b.BackgroundColor3 = BUTTON
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.Text = text
    b.Parent = parent
    round(b, 7)

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)

    return b
end

local function toggle(label, key)
    local b

    local function update()
        b.Text = label .. ": " ..
            (cfg[key] and "ON" or "OFF")
        b.BackgroundColor3 =
            cfg[key] and PURPLE or BUTTON
    end

    b = makeButton(content, "", function()
        cfg[key] = not cfg[key]
        if key == "AimEnabled" and not cfg[key] then
            target = nil
        end
        update()
    end)

    update()
end

local function setting(label, key, minimum, maximum, step)
    local b

    b = makeButton(content, "", function()
        local nextValue = cfg[key] + step

        if nextValue > maximum + 0.001 then
            nextValue = minimum
        end

        cfg[key] = math.floor(nextValue * 100 + 0.5) / 100
        b.Text = label .. ": " .. tostring(cfg[key])
    end)

    b.Text = label .. ": " .. tostring(cfg[key])
end

local function clearPage()
    for _, child in ipairs(content:GetChildren()) do
        if child:IsA("TextButton")
            or child:IsA("TextLabel")
            or child:IsA("TextBox") then
            child:Destroy()
        end
    end
end

local function label(text)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 30)
    t.BackgroundTransparency = 1
    t.TextColor3 = PURPLE
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.Text = text
    t.Parent = content
    return t
end

local pages = {}

pages.AIM = function()
    label("HARD AIMBOT V8")

    toggle("Aimbot", "AimEnabled")
    toggle("Automatic Lock", "AutoAim")
    toggle("Head Only", "HeadOnly")
    toggle("Team Check", "TeamCheck")
    toggle("Wall Check", "WallCheck")

    setting("FOV", "FOV", 50, 1000, 50)
    setting("Sticky FOV", "StickyFOV", 100, 1500, 50)
    setting("Smooth 0-10", "Smoothness", 0, 10, 0.5)

    makeButton(content, "CLEAR TARGET", function()
        target = nil
    end)
end

pages.ESP = function()
    label("PLAYER ESP")

    toggle("Enable ESP", "ESPEnabled")
    toggle("Names", "ESPNames")
    toggle("Distance", "ESPDistance")
    toggle("Highlight", "ESPHighlight")
    toggle("Team Check", "ESPTeamCheck")
end

pages.INFO = function()
    label("GULOSÃO HUB V8")

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 165)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.new(1, 1, 1)
    info.TextWrapped = true
    info.Font = Enum.Font.Gotham
    info.TextSize = 14
    info.Text =
        "RightShift: mostrar/esconder menu\n" ..
        "Botão direito: travar mira\n" ..
        "G: ativar/desativar Aimbot\n\n" ..
        "Smooth 0 = desligado\n" ..
        "Smooth 10 = travamento instantâneo\n\n" ..
        "ESP: nomes, distância e destaque roxo"
    info.Parent = content
end

local function openPage(name)
    clearPage()
    pages[name]()
end

for _, name in ipairs({"AIM", "ESP", "INFO"}) do
    local b = makeButton(tabs, name, function()
        openPage(name)
    end)
    b.Size = UDim2.fromOffset(112, 36)
end

openPage("AIM")

-- AIMBOT

local function getPart(character)
    if not character then return nil end

    if cfg.HeadOnly then
        return character:FindFirstChild("Head")
    end

    return character:FindFirstChild("Head")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
end

local function validTarget(player)
    if not player or player == LP then
        return false
    end

    if cfg.TeamCheck
        and LP.Team ~= nil
        and player.Team == LP.Team then
        return false
    end

    local character = player.Character
    local humanoid = character and
        character:FindFirstChildOfClass("Humanoid")

    return humanoid ~= nil
        and humanoid.Health > 0
        and getPart(character) ~= nil
end

local function screenDistance(part)
    local camera = workspace.CurrentCamera
    if not camera then return math.huge end

    local point, onScreen =
        camera:WorldToViewportPoint(part.Position)

    if not onScreen or point.Z <= 0 then
        return math.huge
    end

    local center = camera.ViewportSize / 2

    return (
        Vector2.new(point.X, point.Y) - center
    ).Magnitude
end

local function visible(player, part)
    if not cfg.WallCheck then return true end

    local camera = workspace.CurrentCamera
    if not camera then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances =
        LP.Character and {LP.Character} or {}

    local origin = camera.CFrame.Position

    local result = workspace:Raycast(
        origin,
        part.Position - origin,
        params
    )

    return not result
        or result.Instance:IsDescendantOf(
            player.Character
        )
end

local function findTarget()
    local best = nil
    local bestDistance = cfg.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if validTarget(player) then
            local part = getPart(player.Character)
            local distance = screenDistance(part)

            if distance < bestDistance
                and visible(player, part) then
                best = player
                bestDistance = distance
            end
        end
    end

    return best
end

-- ESP

local function removeESP(player)
    local data = espObjects[player]
    if not data then return end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" then
            object:Destroy()
        end
    end

    espObjects[player] = nil
end

local function createESP(player)
    removeESP(player)

    if player == LP then return end

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild(
        "HumanoidRootPart"
    )

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GulosaoESP"
    highlight.Adornee = character
    highlight.FillColor = PURPLE
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GulosaoESPInfo"
    billboard.Adornee = root
    billboard.Size = UDim2.fromOffset(220, 55)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = gui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.TextColor3 = PURPLE
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.Text = player.DisplayName
    text.Parent = billboard

    espObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Text = text,
        Character = character
    }
end

local function updateESP()
    if not cfg.ESPEnabled then
        for player in pairs(espObjects) do
            removeESP(player)
        end
        return
    end

    local myRoot = LP.Character and
        LP.Character:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local character = player.Character
            local humanoid = character and
                character:FindFirstChildOfClass("Humanoid")

            local root = character and
                character:FindFirstChild("HumanoidRootPart")

            if not root or not humanoid
                or humanoid.Health <= 0 then
                removeESP(player)
            else
                local data = espObjects[player]

                if not data
                    or data.Character ~= character then
                    createESP(player)
                    data = espObjects[player]
                end

                if data then
                    local sameTeam =
                        cfg.ESPTeamCheck
                        and LP.Team ~= nil
                        and player.Team == LP.Team

                    data.Highlight.Enabled =
                        cfg.ESPHighlight and not sameTeam

                    data.Billboard.Enabled =
                        not sameTeam
                        and (cfg.ESPNames or cfg.ESPDistance)

                    local parts = {}

                    if cfg.ESPNames then
                        table.insert(
                            parts,
                            player.DisplayName
                        )
                    end

                    if cfg.ESPDistance and myRoot then
                        local distance = math.floor(
                            (myRoot.Position -
                                root.Position).Magnitude
                        )

                        table.insert(
                            parts,
                            distance .. " studs"
                        )
                    end

                    data.Text.Text =
                        table.concat(parts, " | ")
                end
            end
        end
    end
end

-- FOV VISUAL

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = gui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = PURPLE
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

-- CONTROLES

table.insert(connections, UIS.InputBegan:Connect(
    function(input, processed)
        if input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end

        if input.KeyCode == Enum.KeyCode.G
            and not processed then
            cfg.AimEnabled = not cfg.AimEnabled
            target = nil
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseButton2
            and not processed then
            holding = true
        end
    end
))

table.insert(connections, UIS.InputEnded:Connect(
    function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton2 then
            holding = false
            target = nil
        end
    end
))

-- LOOP AIMBOT

local renderName = "GulosaoHubV8Aim"

RS:BindToRenderStep(
    renderName,
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if not active then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        fovCircle.Visible = cfg.AimEnabled
        fovCircle.Size = UDim2.fromOffset(
            cfg.FOV * 2,
            cfg.FOV * 2
        )
        fovCircle.Position = UDim2.fromOffset(
            camera.ViewportSize.X / 2,
            camera.ViewportSize.Y / 2
        )

        local shouldAim = cfg.AimEnabled
            and (cfg.AutoAim or holding)

        if not shouldAim then
            target = nil
            return
        end

        if not validTarget(target) then
            target = nil
        end

        if target then
            local part = getPart(target.Character)

            if not part
                or screenDistance(part) > cfg.StickyFOV
                or not visible(target, part) then
                target = nil
            end
        end

        if not target then
            target = findTarget()
        end

        if not target then return end

        local part = getPart(target.Character)
        if not part then return end

        local current = camera.CFrame

        local desired = CFrame.lookAt(
            current.Position,
            part.Position
        )

        local smooth = math.clamp(
            cfg.Smoothness,
            0,
            10
        )

        if smooth >= 10 then
            camera.CFrame = desired
        elseif smooth > 0 then
            camera.CFrame = current:Lerp(
                desired,
                smooth / 10
            )
        end
    end
)

-- ESP LOOP

local espAccumulator = 0

table.insert(connections, RS.Heartbeat:Connect(
    function(dt)
        if not active then return end

        espAccumulator = espAccumulator + dt

        if espAccumulator >= 0.15 then
            espAccumulator = 0
            updateESP()
        end
    end
))

table.insert(connections,
    Players.PlayerRemoving:Connect(function(player)
        removeESP(player)

        if target == player then
            target = nil
        end
    end)
)

-- LIMPEZA

local function cleanup()
    if not active then return end
    active = false

    RS:UnbindFromRenderStep(renderName)

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    for player in pairs(espObjects) do
        removeESP(player)
    end

    gui:Destroy()
end

_G.GulosaoCleanup = cleanup

close.MouseButton1Click:Connect(cleanup)

print("GulosãoHub V8 carregado!")
