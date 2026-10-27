
-- GULOSÃO HUB V6 - HARD AIMBOT
-- LocalScript / Roblox
-- RightShift: mostrar/esconder
-- Botão direito: travar mira
-- G: ligar/desligar aimbot

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- Evitar múltiplas instâncias
if _G.GulosaoV6Cleanup then
    pcall(_G.GulosaoV6Cleanup)
end

local cfg = {
    Enabled = true,
    AutoLock = false,
    HeadOnly = true,
    TeamCheck = true,
    WallCheck = true,
    FOV = 220,
    StickyFOV = 400,
    Smoothness = 1
}

local purple = Color3.fromRGB(150, 75, 255)
local dark = Color3.fromRGB(15, 15, 22)
local panel = Color3.fromRGB(30, 27, 42)

local holding = false
local target = nil
local alive = true
local connections = {}

local gui = Instance.new("ScreenGui")
gui.Name = "GulosaoHubV6"
gui.ResetOnSpawn = false
gui.Parent = PG

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(350, 365)
main.Position = UDim2.new(0.5, -175, 0.5, -182)
main.BackgroundColor3 = dark
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
corner(main, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = purple
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.fromOffset(15, 5)
title.BackgroundTransparency = 1
title.Text = "GULOSÃO HUB V6"
title.TextColor3 = purple
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -24, 1, -65)
container.Position = UDim2.fromOffset(12, 55)
container.BackgroundColor3 = panel
container.BorderSizePixel = 0
container.ScrollBarThickness = 3
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.CanvasSize = UDim2.new()
container.Parent = main
corner(container, 8)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = container

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 9)
padding.PaddingLeft = UDim.new(0, 9)
padding.PaddingRight = UDim.new(0, 9)
padding.PaddingBottom = UDim.new(0, 9)
padding.Parent = container

local function button(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 37)
    b.BackgroundColor3 = Color3.fromRGB(48, 39, 67)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.Text = text
    b.Parent = container
    corner(b, 7)

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

        b.BackgroundColor3 = cfg[key]
            and purple
            or Color3.fromRGB(48, 39, 67)
    end

    b = button("", function()
        cfg[key] = not cfg[key]
        if not cfg.Enabled then
            target = nil
        end
        update()
    end)

    update()
end

local function setting(label, key, min, max, step)
    local b

    b = button("", function()
        cfg[key] = cfg[key] + step

        if cfg[key] > max then
            cfg[key] = min
        end

        cfg[key] = math.round(cfg[key] * 100) / 100
        b.Text = label .. ": " .. cfg[key]
    end)

    b.Text = label .. ": " .. cfg[key]
end

toggle("HARD AIMBOT", "Enabled")
toggle("AUTO LOCK", "AutoLock")
toggle("HEAD ONLY", "HeadOnly")
toggle("TEAM CHECK", "TeamCheck")
toggle("WALL CHECK", "WallCheck")

setting("FOV", "FOV", 50, 600, 25)
setting("STICKY FOV", "StickyFOV", 100, 800, 50)
setting("SMOOTHNESS", "Smoothness", 0.1, 1, 0.1)

button("CLEAR TARGET", function()
    target = nil
end)

local function getPart(char)
    if not char then return nil end

    if cfg.HeadOnly then
        return char:FindFirstChild("Head")
    end

    return char:FindFirstChild("Head")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("HumanoidRootPart")
end

local function valid(p)
    if not p or p == LP then return false end

    if cfg.TeamCheck
        and LP.Team ~= nil
        and p.Team == LP.Team then
        return false
    end

    local char = p.Character
    local hum = char and
        char:FindFirstChildOfClass("Humanoid")

    return hum ~= nil
        and hum.Health > 0
        and getPart(char) ~= nil
end

local function screenDistance(part)
    local cam = workspace.CurrentCamera
    if not cam then return math.huge end

    local pos, visible =
        cam:WorldToViewportPoint(part.Position)

    if not visible or pos.Z <= 0 then
        return math.huge
    end

    local center = cam.ViewportSize / 2

    return (
        Vector2.new(pos.X, pos.Y) - center
    ).Magnitude
end

local function hasLineOfSight(p, part)
    if not cfg.WallCheck then return true end

    local cam = workspace.CurrentCamera
    if not cam then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances =
        LP.Character and {LP.Character} or {}

    local origin = cam.CFrame.Position

    local result = workspace:Raycast(
        origin,
        part.Position - origin,
        params
    )

    return result == nil
        or result.Instance:IsDescendantOf(p.Character)
end

local function findTarget()
    local best = nil
    local bestDistance = cfg.FOV

    for _, p in ipairs(Players:GetPlayers()) do
        if valid(p) then
            local part = getPart(p.Character)
            local distance = screenDistance(part)

            if distance < bestDistance
                and hasLineOfSight(p, part) then
                best = p
                bestDistance = distance
            end
        end
    end

    return best
end

-- FOV visual
local fov = Instance.new("Frame")
fov.AnchorPoint = Vector2.new(0.5, 0.5)
fov.BackgroundTransparency = 1
fov.Parent = gui

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(1, 0)
fc.Parent = fov

local fs = Instance.new("UIStroke")
fs.Color = purple
fs.Thickness = 2
fs.Parent = fov

table.insert(connections, UIS.InputBegan:Connect(
    function(input, processed)
        if input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end

        if input.KeyCode == Enum.KeyCode.G
            and not processed then
            cfg.Enabled = not cfg.Enabled
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

local renderName = "GulosaoHardAimV6"

RunService:BindToRenderStep(
    renderName,
    Enum.RenderPriority.Camera.Value + 1,
    function(dt)
        if not alive then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        fov.Visible = cfg.Enabled
        fov.Size = UDim2.fromOffset(
            cfg.FOV * 2,
            cfg.FOV * 2
        )
        fov.Position = UDim2.fromOffset(
            cam.ViewportSize.X / 2,
            cam.ViewportSize.Y / 2
        )

        local shouldLock = cfg.Enabled
            and (cfg.AutoLock or holding)

        if not shouldLock then
            target = nil
            return
        end

        if not valid(target) then
            target = nil
        end

        if target then
            local part = getPart(target.Character)

            if not part
                or screenDistance(part) > cfg.StickyFOV
                or not hasLineOfSight(target, part) then
                target = nil
            end
        end

        if not target then
            target = findTarget()
        end

        if not target then return end

        local part = getPart(target.Character)
        if not part then return end

        local current = cam.CFrame
        local desired = CFrame.lookAt(
            current.Position,
            part.Position
        )

        local alpha = math.clamp(
            cfg.Smoothness,
            0.1,
            1
        )

        cam.CFrame = current:Lerp(desired, alpha)
    end
)

local function cleanup()
    if not alive then return end
    alive = false

    RunService:UnbindFromRenderStep(renderName)

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    gui:Destroy()
end

_G.GulosaoV6Cleanup = cleanup

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -40, 0, 12)
close.BackgroundColor3 = purple
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Parent = main
corner(close, 6)

close.MouseButton1Click:Connect(cleanup)

print("GulosãoHub V6 Hard Aimbot carregado!")
