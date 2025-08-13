local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

-- Configuration initiale
local image = "rbxassetid://111201744721013"
local mainColor = Color3.fromRGB(31, 15, 77)
local accentColor = Color3.fromRGB(56, 35, 120)
local textColor = Color3.new(1, 1, 1)
local panicColor = Color3.fromRGB(220, 20, 60)
local themeColors = {
    ["Midnight"] = {main = Color3.fromRGB(31, 15, 77), accent = Color3.fromRGB(56, 35, 120)},
    ["Emerald"] = {main = Color3.fromRGB(15, 77, 31), accent = Color3.fromRGB(35, 120, 56)},
    ["Crimson"] = {main = Color3.fromRGB(77, 15, 31), accent = Color3.fromRGB(120, 35, 56)},
    ["Ocean"] = {main = Color3.fromRGB(15, 30, 77), accent = Color3.fromRGB(35, 70, 150)},
    ["Sunset"] = {main = Color3.fromRGB(180, 70, 0), accent = Color3.fromRGB(220, 120, 0)},
    ["Gold"] = {main = Color3.fromRGB(100, 80, 20), accent = Color3.fromRGB(180, 150, 40)},
    ["Ice"] = {main = Color3.fromRGB(20, 60, 100), accent = Color3.fromRGB(40, 120, 180)},
    ["Neon"] = {main = Color3.fromRGB(40, 5, 80), accent = Color3.fromRGB(120, 0, 200)}
}

-- État des fonctionnalités
local config = {
    GodMode = false,
    ESP = true,
    LineOfSight = false,
    SimpleLines = false,
    AimbotHumain = true,
    AimbotFast = false,
    TpBehind = false,
    AutoTP = true,
    InfiniteAmmo = true,
    SpeedBoost = false,
    CurrentSpeed = 16,
    MaxSpeed = 300,
    FOV = 110,
    HealthValue = 100,
    CurrentTheme = "Midnight",
    AutoShoot = false,
    AimbotCooldown = 0.3,
    AimSmoothness = 0.22,
    AutoJump = false,
    AutoWin = false,
    RecordingPoints = false,
    PlayingMacro = false,
    MacroDelay = 0.01,
    NoClip = false,
    NoClipForce = 1.0,
    HitboxExpander = true,
    HitboxSize = 10.0,
    FlyEnabled = false,
    FlySpeed = 50,
    FlyVerticalSpeed = 30,
    NoClipType = "Classic", -- Classic ou Ghost
    ClickTP = false, -- Toggle pour le téléport au clic droit
    AimHead = true,
    AimTorso = false,
}

-- Variables globales
local mouseLocked = true
local menuMinimized = false

-- Éléments d'interface
local gui = {
    ScreenGui = nil,
    MainFrame = nil,
    Tabs = {},
    TabButtons = {},
    ActiveTab = "Aimbot",
    MinimizedIcon = nil,
    IsMinimized = false,
    IsMaximized = false,
    Dragging = false,
    DragStartPos = nil,
    FrameStartPos = nil
}

-- Variables pour l'aimbot
local currentTarget = nil
local holdingMouse = false
local lastShotTime = 0
local fovCircle = nil
local nameDisplay = nil

-- Variables pour l'ESP
local espObjects = {}
local lineOfSightObjects = {}

-- Variables pour le checkpoint
local CheckpointPosition = nil
local SavedPosition = nil
local CanRespawnToCheckpoint = false

-- Variables Dalgona
local recordedPoints = {}
local macroScript = ""
local dalgonaShapes = {
    ["Cercle"] = {
        Vector2.new(400, 300),
        Vector2.new(450, 250),
        Vector2.new(500, 300),
        Vector2.new(450, 350)
    },
    ["Étoile"] = {
        Vector2.new(400, 300),
        Vector2.new(420, 250),
        Vector2.new(450, 280),
        Vector2.new(480, 250),
        Vector2.new(500, 300),
        Vector2.new(480, 350),
        Vector2.new(450, 320),
        Vector2.new(420, 350)
    },
    ["Triangle"] = {
        Vector2.new(1374, 485),
        Vector2.new(842, 259),
        Vector2.new(864, 293),
        Vector2.new(888, 330),
        Vector2.new(906, 362),
        Vector2.new(924, 390),
        Vector2.new(940, 422),
        Vector2.new(962, 450),
        Vector2.new(982, 484),
        Vector2.new(1002, 516),
        Vector2.new(1019, 549),
        Vector2.new(1036, 580),
        Vector2.new(1061, 608),
        Vector2.new(1069, 620),
        Vector2.new(1103, 687),
        Vector2.new(1052, 689),
        Vector2.new(993, 691),
        Vector2.new(949, 694),
        Vector2.new(879, 695),
        Vector2.new(923, 694),
        Vector2.new(837, 699),
        Vector2.new(794, 694),
        Vector2.new(756, 688),
        Vector2.new(728, 693),
        Vector2.new(677, 692),
        Vector2.new(652, 687),
        Vector2.new(611, 686),
        Vector2.new(610, 631),
        Vector2.new(632, 596),
        Vector2.new(652, 559),
        Vector2.new(673, 531),
        Vector2.new(694, 500),
        Vector2.new(712, 453),
        Vector2.new(748, 399),
        Vector2.new(775, 355)
    }
}

-- Variables NoClip
local noClipConnection = nil
local originalCollisions = {}
local ghostParts = {}

-- Variables Fly
local flyConnections = {}
local flyBodyVelocity = nil
local flyBodyGyro = nil

-- Variables Hitbox
local originalSizes = {}
local hitboxAdornments = {}
local HITBOX_INCREASE_FACTOR = config.HitboxSize

-- Notifications
local function sendNotification(title, text, duration, icon)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration;
            Icon = icon or "https://cdn.discordapp.com/avatars/1223807225881956477/0b02158183f7fe2a07531ac746850796.png?size=1024";
        })
    end)
end

-- Fonction utilitaire pour obtenir la partie à viser
local function getAimPart(character)
    if not character then return nil end
    
    if config.AimHead then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end
end

-- Fonction pour augmenter les hitboxes et les afficher
local function increaseAndShowHitbox(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if not originalSizes[part] then
                originalSizes[part] = part.Size
            end
            
            part.Size = originalSizes[part] * HITBOX_INCREASE_FACTOR

            if not hitboxAdornments[part] then
                local adornment = Instance.new("BoxHandleAdornment")
                adornment.Size = part.Size
                adornment.Adornee = part
                adornment.AlwaysOnTop = true
                adornment.ZIndex = 10
                adornment.Transparency = 0.97
                adornment.Color3 = Color3.new(1, 0, 0)
                adornment.Parent = part
                hitboxAdornments[part] = adornment
            end
        end
    end
end

-- Fonction pour restaurer les hitboxes originales
local function restoreOriginalHitbox(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and originalSizes[part] then
            part.Size = originalSizes[part]
            if hitboxAdornments[part] then
                hitboxAdornments[part]:Destroy()
                hitboxAdornments[part] = nil
            end
            originalSizes[part] = nil
        end
    end
end

-- Gestion des joueurs
local function handlePlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        if config.HitboxExpander then
            increaseAndShowHitbox(character)
        end
    end)

    player.CharacterRemoving:Connect(function(character)
        restoreOriginalHitbox(character)
    end)

    if player.Character and config.HitboxExpander then
        increaseAndShowHitbox(player.Character)
    end
end

-- Initialisation Hitbox
for _, player in ipairs(Players:GetPlayers()) do
    handlePlayer(player)
end

-- Fonction utilitaire pour les couleurs basées sur les PV
local function getHealthColor(health, maxHealth)
    maxHealth = maxHealth > 0 and maxHealth or 100
    local ratio = math.clamp(health / maxHealth, 0, 1)
    return Color3.new(1 - ratio, ratio, 0)
end

-- Fonctions de cheat
local function createESP(player)
    if player == LocalPlayer then return end
    local esp = {}
    
    esp.box = Drawing.new("Square")
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Transparency = 1
    esp.box.Visible = config.ESP

    esp.name = Drawing.new("Text")
    esp.name.Color = Color3.new(1, 1, 1)
    esp.name.Size = 15
    esp.name.Transparency = 1
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Visible = config.ESP
    
    esp.line = Drawing.new("Line")
    esp.line.Thickness = 1
    esp.line.Transparency = 1
    esp.line.Visible = config.LineOfSight

    esp.simpleLine = Drawing.new("Line")
    esp.simpleLine.Thickness = 1
    esp.simpleLine.Transparency = 1
    esp.simpleLine.Visible = config.SimpleLines

    espObjects[player] = esp
end

local function updateESP()
    for player, esp in pairs(espObjects) do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            esp.box.Visible = false
            esp.name.Visible = false
            esp.line.Visible = false
            esp.simpleLine.Visible = false
            return
        end

        local character = player.Character
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if head and torso and humanoid then
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
            local torsoPos, torsoOnScreen = Camera:WorldToViewportPoint(torso.Position)
            
            if headOnScreen and torsoOnScreen then
                local height = math.abs(headPos.Y - torsoPos.Y) * 2
                local width = height * 0.6

                local healthColor = getHealthColor(humanoid.Health, humanoid.MaxHealth)
                esp.box.Color = healthColor
                
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(torsoPos.X - width/2, headPos.Y - height/2)
                esp.box.Visible = config.ESP

                esp.name.Position = Vector2.new(torsoPos.X, headPos.Y - height/2 - 15)
                esp.name.Text = player.Name
                esp.name.Visible = config.ESP
                
                local screenBottom = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                esp.simpleLine.From = screenBottom
                esp.simpleLine.To = Vector2.new(torsoPos.X, torsoPos.Y)
                esp.simpleLine.Color = healthColor
                esp.simpleLine.Visible = config.SimpleLines
                
                if config.LineOfSight then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local localRoot = LocalPlayer.Character.HumanoidRootPart.Position
                        local targetRoot = root.Position
                        
                        local direction = (targetRoot - localRoot).Unit
                        local distance = (targetRoot - localRoot).Magnitude
                        
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                        local rayResult = workspace:Raycast(localRoot, direction * distance, raycastParams)
                        
                        local endPoint = rayResult and rayResult.Position or targetRoot
                        
                        local startScreenPos, startVisible = Camera:WorldToViewportPoint(localRoot)
                        local endScreenPos, endVisible = Camera:WorldToViewportPoint(endPoint)
                        
                        if startVisible and endVisible then
                            esp.line.From = Vector2.new(startScreenPos.X, startScreenPos.Y)
                            esp.line.To = Vector2.new(endScreenPos.X, endScreenPos.Y)
                            esp.line.Color = healthColor
                            esp.line.Visible = true
                        else
                            esp.line.Visible = false
                        end
                    end
                else
                    esp.line.Visible = false
                end
            else
                esp.box.Visible = false
                esp.name.Visible = false
                esp.line.Visible = false
                esp.simpleLine.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
            esp.line.Visible = false
            esp.simpleLine.Visible = false
        end
    end
end

-- God Mode
local function enforceGodMode(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = config.GodMode and math.huge or 100
        humanoid.Health = config.GodMode and math.huge or 100
    end
end

-- Speed
local function updateSpeed()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = config.SpeedBoost and config.CurrentSpeed or 16
    end
end

-- Initialisation de l'aimbot
local function initAimbot()
    if fovCircle then
        fovCircle:Remove()
        nameDisplay:Remove()
    end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(0, 255, 0)
    fovCircle.Thickness = 1.5
    fovCircle.Radius = config.FOV
    fovCircle.Transparency = 0.85
    fovCircle.Visible = config.AimbotHumain
    fovCircle.Filled = false

    nameDisplay = Drawing.new("Text")
    nameDisplay.Size = 18
    nameDisplay.Center = true
    nameDisplay.Outline = true
    nameDisplay.Font = 2
    nameDisplay.Visible = false
    nameDisplay.Color = Color3.fromRGB(0, 255, 0)
end

local function isVisible(head)
    local originPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not originPart then return false end
    local origin = originPart.Position
    local dir = (head.Position - origin).Unit * (head.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = workspace:Raycast(origin, dir, raycastParams)
    return result and result.Instance and result.Instance:IsDescendantOf(head.Parent)
end

local function isTargetValid(player)
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    local char = player.Character
    if not char then return false end
    local part = getAimPart(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not part or not hum or hum.Health <= 0 then return false end
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    if dist > config.FOV then return false end
    return isVisible(part)
end

local function getClosestTarget()
    local bestTarget, minDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if isTargetValid(player) then
            local char = player.Character
            local part = getAimPart(char)
            local screenPos = Camera:WorldToViewportPoint(part.Position)
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist < minDist then
                bestTarget = player
                minDist = dist
            end
        end
    end
    return bestTarget
end

local function moveCameraSmooth(targetPos)
    local origin = Camera.CFrame.Position
    local dir = (targetPos - origin).Unit
    local smoothLook = Camera.CFrame.LookVector:Lerp(dir, config.AimSmoothness)
    Camera.CFrame = CFrame.new(origin, origin + smoothLook)
end

-- TP Behind
local tpBehindCurrentTarget = nil
local tpBehindOffset = 5

local function getClosestEnemy()
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local localPos = localCharacter.HumanoidRootPart.Position
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                continue
            end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Infinite Ammo
local function setInfiniteAmmo(tool)
    local ammo = tool:FindFirstChild("Ammo")
    if ammo and type(ammo.Value) == "number" then
        ammo.Value = math.huge
    end
end

local function infiniteBullet()
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                setInfiniteAmmo(tool)
            end
        end
    end
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                setInfiniteAmmo(tool)
            end
        end
    end
end

-- Auto TP when below map
local function getFarthestPlayer()
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local localPos = localCharacter.HumanoidRootPart.Position
    local farthestPlayer = nil
    local farthestDistance = 0

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                continue
            end
            local distance = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
            if distance > farthestDistance then
                farthestDistance = distance
                farthestPlayer = player
            end
        end
    end
    return farthestPlayer
end

-- Fonctions Dalgona
local function startRecording()
    recordedPoints = {}
    config.RecordingPoints = true
    sendNotification("Dalgona", "Enregistrement démarré. Cliquez pour ajouter des points", 3, image)
end

local function stopRecording()
    config.RecordingPoints = false
    sendNotification("Dalgona", "Enregistrement terminé. Points: " .. #recordedPoints, 3, image)
end

local function playMacro()
    if #recordedPoints < 2 then return end
    
    config.PlayingMacro = true
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    
    for i, point in ipairs(recordedPoints) do
        VirtualInputManager:SendMouseMoveEvent(point.X, point.Y, game)
        task.wait(config.MacroDelay)
    end
    
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    config.PlayingMacro = false
end

local function generateMacroScript()
    local scriptLines = {"local VirtualInputManager = game:GetService('VirtualInputManager')"}
    table.insert(scriptLines, "VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)")
    
    for _, point in ipairs(recordedPoints) do
        table.insert(scriptLines, string.format("VirtualInputManager:SendMouseMoveEvent(%d, %d, game)", point.X, point.Y))
    end
    
    table.insert(scriptLines, "VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)")
    return table.concat(scriptLines, "\n")
end

local function loadShape(shapeName)
    if dalgonaShapes[shapeName] then
        recordedPoints = dalgonaShapes[shapeName]
        sendNotification("Dalgona", "Forme chargée: " .. shapeName, 3, image)
        return true
    end
    return false
end

-- NoClip functions
local function setupNoClip()
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end

    if config.NoClip then
        if config.NoClipType == "Ghost" then
            noClipConnection = RunService.Stepped:Connect(function()
                if not LocalPlayer.Character then return end
                
                for part, _ in pairs(ghostParts) do
                    if part and part.Parent then
                        part.Transparency = ghostParts[part].transparency
                        part.CanCollide = ghostParts[part].canCollide
                        ghostParts[part] = nil
                    end
                end
                
                local character = LocalPlayer.Character
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local overlapping = workspace:GetPartsInPart(part)
                        for _, otherPart in ipairs(overlapping) do
                            if otherPart:IsA("BasePart") and otherPart.CanCollide and otherPart.Transparency < 0.5 then
                                if not ghostParts[otherPart] then
                                    ghostParts[otherPart] = {
                                        transparency = otherPart.Transparency,
                                        canCollide = otherPart.CanCollide
                                    }
                                    otherPart.Transparency = 0.8
                                    otherPart.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
        else
            local function onTouched(part)
                if not part:IsA("BasePart") then return end
                if not part.Anchored then return end
                if not part.CanCollide then return end

                local character = LocalPlayer.Character
                if not character then return end

                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                if part.Position.Y < (hrp.Position.Y - hrp.Size.Y) then return end

                if not originalCollisions[part] then
                    originalCollisions[part] = {
                        CanCollide = part.CanCollide,
                        Anchored = part.Anchored
                    }
                end

                part.CanCollide = false
            end

            local function setupCharacter(char)
                local hrp = char:WaitForChild("HumanoidRootPart")
                noClipConnection = hrp.Touched:Connect(onTouched)
            end

            if LocalPlayer.Character then
                setupCharacter(LocalPlayer.Character)
            end
        end
    else
        for part, data in pairs(originalCollisions) do
            if part and part.Parent then
                part.CanCollide = data.CanCollide
            end
        end
        originalCollisions = {}
        
        for part, data in pairs(ghostParts) do
            if part and part.Parent then
                part.Transparency = data.transparency
                part.CanCollide = data.canCollide
            end
        end
        ghostParts = {}
    end
end

-- Hitbox functions
local function updateHitboxes()
    for player, adornments in pairs(hitboxAdornments) do
        for _, adornment in pairs(adornments) do
            adornment:Destroy()
        end
    end
    hitboxAdornments = {}

    if config.HitboxExpander then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                hitboxAdornments[player] = {}

                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local adornment = Instance.new("BoxHandleAdornment")
                        adornment.Size = part.Size * config.HitboxSize
                        adornment.Adornee = part
                        adornment.AlwaysOnTop = true
                        adornment.ZIndex = 10
                        adornment.Transparency = 0.97
                        adornment.Color3 = Color3.new(1, 0, 0)
                        adornment.Parent = part
                        table.insert(hitboxAdornments[player], adornment)
                    end
                end
            end
        end
    end
end

local function handlePlayerHitbox(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        if config.HitboxExpander then
            hitboxAdornments[player] = {}
            
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local adornment = Instance.new("BoxHandleAdornment")
                    adornment.Size = part.Size * config.HitboxSize
                    adornment.Adornee = part
                    adornment.AlwaysOnTop = true
                    adornment.ZIndex = 10
                    adornment.Transparency = 0.97
                    adornment.Color3 = Color3.new(1, 0, 0)
                    adornment.Parent = part
                    table.insert(hitboxAdornments[player], adornment)
                end
            end
        end
    end)

    if player.Character and config.HitboxExpander then
        hitboxAdornments[player] = {}
        
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                local adornment = Instance.new("BoxHandleAdornment")
                adornment.Size = part.Size * config.HitboxSize
                adornment.Adornee = part
                adornment.AlwaysOnTop = true
                adornment.ZIndex = 10
                adornment.Transparency = 0.97
                adornment.Color3 = Color3.new(1, 0, 0)
                adornment.Parent = part
                table.insert(hitboxAdornments[player], adornment)
            end
        end
    end
end

local function createCheckbox(parent, name, state, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 20)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local box = Instance.new("Frame")
    box.Name = "CheckBox"
    box.Size = UDim2.new(0, 15, 0, 15)
    box.Position = UDim2.new(0, 0, 0, 2)
    box.BorderSizePixel = 1
    box.BorderColor3 = textColor
    box.BackgroundColor3 = state and accentColor or Color3.fromRGB(40, 40, 40)
    box.Parent = frame
    
    local check = Instance.new("TextLabel")
    check.Name = "CheckMark"
    check.Text = "✓"
    check.TextColor3 = textColor
    check.BackgroundTransparency = 1
    check.Size = UDim2.new(1, 0, 1, 0)
    check.Visible = state
    check.Font = Enum.Font.GothamBold
    check.TextSize = 12
    check.Parent = box
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = textColor
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -25, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local function updateCheckbox(newState)
        state = newState
        box.BackgroundColor3 = state and accentColor or Color3.fromRGB(40, 40, 40)
        check.Visible = state
        callback(state)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateCheckbox(not state)
            return Enum.ContextActionResult.Sink
        end
    end)
    
    return frame, updateCheckbox
end

-- Interface functions
local function createRoundedFrame(parent, size, position, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = color
    frame.Size = size
    frame.Position = position
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(cornerRadius, 0)
    corner.Parent = frame
    
    frame.Parent = parent
    return frame
end

local function createButton(parent, size, position, text, color, textCol)
    local button = createRoundedFrame(parent, size, position, color, 0.2)
    button.BackgroundTransparency = 0.3
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = textCol
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = button
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            return Enum.ContextActionResult.Sink
        end
    end)
    
    return button
end

local function createTextBox(parent, size, position, text, placeholder)
    local textBoxFrame = createRoundedFrame(parent, size, position, Color3.fromRGB(40, 40, 40), 0.1)
    textBoxFrame.BackgroundTransparency = 0.8
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.95, 0, 0.9, 0)
    textBox.Position = UDim2.new(0.025, 0, 0.05, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = text
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = textColor
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 12
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.TextWrapped = true
    textBox.ClearTextOnFocus = false
    textBox.Parent = textBoxFrame
    
    textBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            return Enum.ContextActionResult.Sink
        end
    end)
    
    return textBox
end

local function createToggle(parent, name, state, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = textColor
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = createRoundedFrame(frame, UDim2.new(0, 45, 0, 20), UDim2.new(0.8, 0, 0.5, -10), 
        state and accentColor or Color3.fromRGB(70, 70, 70), 0.5)
    
    local toggleDot = createRoundedFrame(toggle, UDim2.new(0, 12, 0, 12), 
        state and UDim2.new(0.7, 0, 0.5, -6) or UDim2.new(0.1, 0, 0.5, -6), 
        textColor, 0.5)
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local bgTween = TweenService:Create(toggle, tweenInfo, {
                BackgroundColor3 = state and accentColor or Color3.fromRGB(70, 70, 70)
            })
            
            local dotTween = TweenService:Create(toggleDot, tweenInfo, {
                Position = state and UDim2.new(0.7, 0, 0.5, -6) or UDim2.new(0.1, 0, 0.5, -6)
            })
            
            bgTween:Play()
            dotTween:Play()
            
            callback(state)
            sendNotification("Script", name .. (state and " activé" or " désactivé"), 3, image)
            
            return Enum.ContextActionResult.Sink
        end
    end)
    
    return frame
end

local function createSlider(parent, name, min, max, current, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = textColor
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(current)
    valueLabel.TextColor3 = textColor
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -40, 0, 0)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderTrack = createRoundedFrame(frame, UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 0, 30), 
        Color3.fromRGB(70, 70, 70), 3)
    
    local sliderFill = createRoundedFrame(sliderTrack, UDim2.new((current - min) / (max - min), 0, 1, 0), 
        UDim2.new(0, 0, 0, 0), accentColor, 3)
    
    local sliderDot = createRoundedFrame(sliderTrack, UDim2.new(0, 16, 0, 16), 
        UDim2.new((current - min) / (max - min), -8, 0.5, -8), textColor, 0.5)
    
    local sliding = false
    
    local function updateValue(value)
        value = math.clamp(value, min, max)
        current = value
        valueLabel.Text = tostring(math.floor(value * 100) / 100)
        
        local fillWidth = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(fillWidth, 0, 1, 0)
        sliderDot.Position = UDim2.new(fillWidth, -8, 0.5, -8)
        
        callback(value)
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            local posX = input.Position.X - sliderTrack.AbsolutePosition.X
            local value = min + (posX / sliderTrack.AbsoluteSize.X) * (max - min)
            updateValue(value)
            
            return Enum.ContextActionResult.Sink
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local posX = input.Position.X - sliderTrack.AbsolutePosition.X
            local value = min + (posX / sliderTrack.AbsoluteSize.X) * (max - min)
            updateValue(value)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    return frame
end

local function createMinimizedIcon()
    if gui.MinimizedIcon then gui.MinimizedIcon:Destroy() end
    
    gui.MinimizedIcon = createRoundedFrame(gui.ScreenGui, UDim2.new(0, 40, 0, 40), 
        UDim2.new(1, -50, 0, 10), mainColor, 0.3)
    
    local icon = Instance.new("ImageLabel")
    icon.Image = "rbxassetid://111201744721013"
    icon.Size = UDim2.new(0.7, 0, 0.7, 0)
    icon.Position = UDim2.new(0.15, 0, 0.15, 0)
    icon.BackgroundTransparency = 1
    icon.Parent = gui.MinimizedIcon
    
    gui.MinimizedIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            gui.MainFrame.Visible = true
            gui.MinimizedIcon.Visible = false
            gui.IsMinimized = false
            menuMinimized = false
            return Enum.ContextActionResult.Sink
        end
    end)
end

-- Checkpoint
local function setCheckpointFromCharacter(char)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if root then
        CheckpointPosition = root.CFrame
        sendNotification("Script", "Position sauvegardée au lancement.", 5, image)
    end
end

local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    humanoid.Died:Connect(function()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            SavedPosition = root.CFrame
            CanRespawnToCheckpoint = true
            sendNotification("Script", "Appuyer sur P pour respawn au checkpoint.", 5, image)
        end
    end)
end

local function tryReviveCharacter()
    local char = LocalPlayer.Character
    if not char then return false end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.MaxHealth or 100
        return humanoid.Health > 0
    end
    return false
end

local function teleportToCheckpoint()
    local char = LocalPlayer.Character
    if not char or not CheckpointPosition then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        wait(0.2)
        root.CFrame = SavedPosition or CheckpointPosition
    end
end

-- Aimbot Fast
local raycastParamsFast = RaycastParams.new()
raycastParamsFast.FilterType = Enum.RaycastFilterType.Blacklist
raycastParamsFast.FilterDescendantsInstances = {LocalPlayer.Character}

local function isVisibleFast(targetHead)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Head") then
        return false
    end
    local origin = character.Head.Position
    local direction = (targetHead.Position - origin).Unit * (targetHead.Position - origin).Magnitude
    local result = workspace:Raycast(origin, direction, raycastParamsFast)
    if result and result.Instance then
        if result.Instance:IsDescendantOf(targetHead.Parent) then
            return true
        else
            return false
        end
    end
    return true
end

local function getClosestVisibleEnemy()
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local localPos = localCharacter.HumanoidRootPart.Position
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            if LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
                continue
            end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = player.Character:FindFirstChild("Head")
                if isVisibleFast(head) then
                    local distance = (player.Character.HumanoidRootPart.Position - localPos).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function startShooting()
    if not holdingMouse then
        holdingMouse = true
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    end
end

local function stopShooting()
    if holdingMouse then
        holdingMouse = false
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

-- Fonction pour basculer l'état de verrouillage de la souris
local function toggleMouseLock()
    mouseLocked = not mouseLocked
    if mouseLocked then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        sendNotification("Souris", "Souris verrouillée", 2, image)
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        sendNotification("Souris", "Souris déverrouillée", 2, image)
    end
end

-- Fonction pour basculer l'état du menu
local function toggleMenu()
    if gui.IsMinimized then
        gui.MainFrame.Visible = true
        if gui.MinimizedIcon then
            gui.MinimizedIcon.Visible = false
        end
        gui.IsMinimized = false
        menuMinimized = false
    else
        gui.MainFrame.Visible = false
        createMinimizedIcon()
        gui.MinimizedIcon.Visible = true
        gui.IsMinimized = true
        menuMinimized = true
    end
end

-- GIVE functions
local function createTeleportTool()
    local tool = Instance.new("Tool")
    tool.Name = "TP TOOL"
    tool.RequiresHandle = false
    tool.CanBeDropped = false

    local script = Instance.new("Script", tool)
    script.Name = "TeleportScript"
    
    script.Source = [[
        local Tool = script.Parent
        local Player = game:GetService("Players").LocalPlayer
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local Camera = workspace.CurrentCamera
        local ContextActionService = game:GetService("ContextActionService")
        
        Tool.Activated:Connect(function()
        end)
        
        local function onRightClick(actionName, inputState)
            if inputState == Enum.UserInputState.Begin then
                local mousePos = UserInputService:GetMouseLocation()
                local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                raycastParams.FilterDescendantsInstances = {Player.Character}
                
                local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
                if result then
                    local position = result.Position
                    local character = Player.Character
                    if character then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            local safePosition = position + Vector3.new(0, 3, 0)
                            local safeCFrame = CFrame.new(safePosition)
                            
                            humanoidRootPart.CFrame = safeCFrame
                        end
                    end
                end
            end
        end
        
        Tool.Equipped:Connect(function()
            Tool.TextureId = "rbxassetid://70746737"
            ContextActionService:BindAction("RightClickTeleport", onRightClick, false, Enum.UserInputType.MouseButton2)
        end)
        
        Tool.Unequipped:Connect(function()
            ContextActionService:UnbindAction("RightClickTeleport")
        end)
    ]]
    
    return tool
end

local function fetchGameItems()
    local items = {}
    local seen = {}
    
    table.insert(items, createTeleportTool())
    seen["TP TOOL"] = true
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not seen[obj.Name] then
            table.insert(items, obj)
            seen[obj.Name] = true
        end
    end
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") and not seen[obj.Name] then
            table.insert(items, obj)
            seen[obj.Name] = true
        end
    end
    
    return items
end

local function giveItem(item)
    if item and LocalPlayer.Character then
        local clone = item:Clone()
        
        if clone.Name == "TP TOOL" then
            local teleportScript = clone:FindFirstChild("TeleportScript")
            if teleportScript then
                teleportScript.Parent = clone
            end
        end
        
        clone.Parent = LocalPlayer.Backpack
        sendNotification("GIVE", "Objet donné: " .. item.Name, 3, image)
    end
end

-- Position functions
local function getPlayerPosition()
    if LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            return root.Position
        end
    end
    return Vector3.new(0, 0, 0)
end

local function autoJump()
    if config.AutoJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Jump = true
        end
    end
end

-- Fly functions
local function enableFly()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    flyBodyVelocity.P = 10000
    flyBodyVelocity.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
    flyBodyGyro.P = 10000
    flyBodyGyro.D = 100
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    
    config.NoClip = true
    setupNoClip()
    
    table.insert(flyConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Space then
            flyBodyVelocity.Velocity = Vector3.new(flyBodyVelocity.Velocity.X, config.FlyVerticalSpeed, flyBodyVelocity.Velocity.Z)
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            flyBodyVelocity.Velocity = Vector3.new(flyBodyVelocity.Velocity.X, -config.FlyVerticalSpeed, flyBodyVelocity.Velocity.Z)
        end
    end))
    
    table.insert(flyConnections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            flyBodyVelocity.Velocity = Vector3.new(flyBodyVelocity.Velocity.X, 0, flyBodyVelocity.Velocity.Z)
        end
    end))
    
    table.insert(flyConnections, RunService.Heartbeat:Connect(function()
        if not flyBodyVelocity or not flyBodyGyro then return end
        
        flyBodyGyro.CFrame = Camera.CFrame
        
        local forward = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        local velocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity - right
        end
        
        flyBodyVelocity.Velocity = velocity * config.FlySpeed
    end))
end

local function disableFly()
    config.NoClip = false
    setupNoClip()
    
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    
    for _, conn in ipairs(flyConnections) do
        conn:Disconnect()
    end
    flyConnections = {}
end

-- Fonction pour le téléport au clic droit
local function handleClickTeleport(input, gameProcessed)
    if gameProcessed or not config.ClickTP or input.UserInputType ~= Enum.UserInputType.MouseButton2 then
        return
    end
    
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    if result then
        local position = result.Position
        local character = LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local safePosition = position + Vector3.new(0, 3, 0)
                humanoidRootPart.CFrame = CFrame.new(safePosition)
            end
        end
    end
end

local function createWindow()
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        
        if gui.ScreenGui then
            gui.ScreenGui:Destroy()
        end
        
        gui.ScreenGui = Instance.new("ScreenGui")
        gui.ScreenGui.Name = "CheatMenu"
        gui.ScreenGui.Parent = playerGui
        gui.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.ScreenGui.ResetOnSpawn = false
        
        if gui.MainFrame then gui.MainFrame:Destroy() end
        
        gui.MainFrame = createRoundedFrame(gui.ScreenGui, UDim2.new(0, 400, 0, 500), 
            UDim2.new(0.5, -200, 0.5, -250), mainColor, 0.02)
        gui.MainFrame.ZIndex = 10
        
        local titleBar = createRoundedFrame(gui.MainFrame, UDim2.new(1, 0, 0, 30), 
            UDim2.new(0, 0, 0, 0), Color3.new(0, 0, 0), 0)
        titleBar.BackgroundTransparency = 1
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                gui.Dragging = true
                gui.DragStartPos = input.Position
                gui.FrameStartPos = gui.MainFrame.Position
                return Enum.ContextActionResult.Sink
            end
        end)
        
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                gui.Dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if gui.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - gui.DragStartPos
                gui.MainFrame.Position = UDim2.new(
                    gui.FrameStartPos.X.Scale, 
                    gui.FrameStartPos.X.Offset + delta.X,
                    gui.FrameStartPos.Y.Scale, 
                    gui.FrameStartPos.Y.Offset + delta.Y
                )
            end
        end)
        
        local panicBtn = createButton(titleBar, UDim2.new(0, 60, 0, 25), UDim2.new(0, 5, 0.5, -12.5), "PANIC", panicColor, Color3.new(1, 1, 1))
        
        panicBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                game.Players.LocalPlayer:Kick("Panic button pressed! Rejoin to disable cheats.")
                return Enum.ContextActionResult.Sink
            end
        end)
        
        local title = Instance.new("TextLabel")
        title.Text = "FPS Game Cheat - By Ibzable v4.0"
        title.TextColor3 = textColor
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(0.5, 0, 1, 0)
        title.Position = UDim2.new(0.2, 0, 0, 0)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.Parent = titleBar
        
        local minimizeBtn = createButton(titleBar, UDim2.new(0, 25, 0, 25), 
            UDim2.new(0.980, -80, 0.5, -12.5), "–", accentColor, Color3.new(1, 1, 1))

        local maximizeBtn = createButton(titleBar, UDim2.new(0, 25, 0, 25), 
            UDim2.new(0.980, -50, 0.5, -12.5), "▢", accentColor, Color3.new(1, 1, 1))

        local closeBtn = createButton(titleBar, UDim2.new(0, 25, 0, 25), 
            UDim2.new(0.980, -20, 0.5, -12.5), "X", panicColor, Color3.new(1, 1, 1))
        
        minimizeBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggleMenu()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        maximizeBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                gui.IsMaximized = not gui.IsMaximized
                gui.MainFrame.Size = gui.IsMaximized and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 400, 0, 500)
                gui.MainFrame.Position = gui.IsMaximized and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -200, 0.5, -250)
                return Enum.ContextActionResult.Sink
            end
        end)
        
        closeBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
            config.GodMode = false
            config.ESP = false
            config.LineOfSight = false
            config.SimpleLines = false
            config.AimbotHumain = false
            config.AimbotFast = false
            config.TpBehind = false
            config.AutoTP = false
            config.InfiniteAmmo = false
            config.SpeedBoost = false
            config.CurrentSpeed = 16
            config.HealthValue = 100
            config.AutoShoot = false
            config.AimbotCooldown = nil
            config.AimSmoothness = nil
            config.AutoJump = false
            config.AutoWin = false
            config.RecordingPoints = false
            config.PlayingMacro = false
            config.MacroDelay = nil
            config.NoClip = false
            config.NoClipForce = nil
            config.HitboxExpander = false
            config.HitboxSize = nil
            config.FlyEnabled = false
            config.FlySpeed = nil
            config.FlyVerticalSpeed = nil
            config.NoClipType = nil
            config.ClickTP = false
            config.AimHead = false
            config.AimTorso = false
                
                for _, esp in pairs(espObjects) do
                    esp.box:Remove()
                    esp.name:Remove()
                    if esp.line then
                        esp.line:Remove()
                    end
                end
                espObjects = {}
                
                enforceGodMode(LocalPlayer.Character)
                updateSpeed()
                
                wait(1)
                gui.ScreenGui:Destroy()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        local tabContainer = createRoundedFrame(gui.MainFrame, UDim2.new(0, 100, 1, -40), 
            UDim2.new(0, 0, 0, 30), accentColor, 0)
        tabContainer.BackgroundTransparency = 0.3
        
        local contentFrame = createRoundedFrame(gui.MainFrame, UDim2.new(1, -110, 1, -40), 
            UDim2.new(0, 100, 0, 30), Color3.fromRGB(40, 40, 40), 0)
        contentFrame.BackgroundTransparency = 0.9
        
        local tabNames = {"Aimbot", "ESP", "TP", "Health", "Speed", "Theme", "Divers", "GIVE", "Dalgona", "Hitbox", "Fly", "NoClip"}
        for i, name in ipairs(tabNames) do
            local tabBtn = createButton(tabContainer, UDim2.new(1, -10, 0, 30), 
                UDim2.new(0, 5, 0, 10 + (i-1)*35), name, accentColor, Color3.new(1, 1, 1))

            tabBtn.BackgroundTransparency = 0.5
            
            local label = tabBtn:FindFirstChildOfClass("TextLabel")
            label.Text = name
            
            tabBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    gui.ActiveTab = name
                    for _, child in ipairs(contentFrame:GetChildren()) do
                        if child:IsA("Frame") then
                            child.Visible = false
                        end
                    end
                    
                    if gui.Tabs[name] then
                        gui.Tabs[name].Visible = true
                    end
                    return Enum.ContextActionResult.Sink
                end
            end)
            
            gui.TabButtons[name] = tabBtn
        end
        
        -- Onglet Aimbot
        local aimbotTab = Instance.new("Frame")
        aimbotTab.Size = UDim2.new(1, 0, 1, 0)
        aimbotTab.BackgroundTransparency = 1
        aimbotTab.Visible = gui.ActiveTab == "Aimbot"
        aimbotTab.Parent = contentFrame

        local aimbotScroll = Instance.new("ScrollingFrame")
        aimbotScroll.Size = UDim2.new(1, 0, 1, 0)
        aimbotScroll.BackgroundTransparency = 1
        aimbotScroll.ScrollBarThickness = 5
        aimbotScroll.CanvasSize = UDim2.new(0, 0, 0, 350)
        aimbotScroll.Parent = aimbotTab

        local aimbotContent = Instance.new("Frame")
        aimbotContent.Size = UDim2.new(1, 0, 0, 350)
        aimbotContent.BackgroundTransparency = 1
        aimbotContent.Parent = aimbotScroll

        createToggle(aimbotContent, "Activer Aimbot Humain", config.AimbotHumain, function(state)
            config.AimbotHumain = state
            config.AimbotFast = false
            
            if state then
                initAimbot()
            elseif fovCircle then
                fovCircle.Visible = false
                nameDisplay.Visible = false
                currentTarget = nil
                holdingMouse = false
                stopShooting()
            end
        end)

        local headCheckbox, updateHeadCheckbox = createCheckbox(aimbotContent, "Head", config.AimHead, function(state)
            config.AimHead = state
            if state then
                config.AimTorso = false
                updateTorsoCheckbox(false)
            end
        end)
        headCheckbox.Position = UDim2.new(0, 10, 0, 40)

        local torsoCheckbox, updateTorsoCheckbox = createCheckbox(aimbotContent, "Torso", config.AimTorso, function(state)
            config.AimTorso = state
            if state then
                config.AimHead = false
                updateHeadCheckbox(false)
            end
        end)
        torsoCheckbox.Position = UDim2.new(0, 10, 0, 70)

        createSlider(aimbotContent, "FOV", 20, 300, config.FOV, function(value)
            config.FOV = value
            if fovCircle then
                fovCircle.Radius = value
            end
        end).Position = UDim2.new(0, 10, 0, 100)

        createToggle(aimbotContent, "Auto Shoot", config.AutoShoot, function(state)
            config.AutoShoot = state
        end).Position = UDim2.new(0, 10, 0, 130)

        createToggle(aimbotContent, "Activer Aimbot Fast", config.AimbotFast, function(state)
            config.AimbotFast = state
            config.AimbotHumain = false
            
            if state then
                initAimbot()
            end
        end).Position = UDim2.new(0, 10, 0, 170)

        createSlider(aimbotContent, "Cooldown", 0.1, 2, config.AimbotCooldown, function(value)
            config.AimbotCooldown = value
        end).Position = UDim2.new(0, 10, 0, 230)

        createSlider(aimbotContent, "Smoothness", 0.01, 1, config.AimSmoothness, function(value)
            config.AimSmoothness = value
        end).Position = UDim2.new(0, 10, 0, 290)

        gui.Tabs["Aimbot"] = aimbotTab
        
        -- Onglet ESP
        local espTab = Instance.new("Frame")
        espTab.Size = UDim2.new(1, 0, 1, 0)
        espTab.BackgroundTransparency = 1
        espTab.Visible = gui.ActiveTab == "ESP"
        espTab.Parent = contentFrame
        
        createToggle(espTab, "Activer ESP", config.ESP, function(state)
            config.ESP = state
            if state then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        createESP(player)
                    end
                end
            else
                for _, esp in pairs(espObjects) do
                    esp.box:Remove()
                    esp.name:Remove()
                    if esp.line then
                        esp.line:Remove()
                    end
                end
                espObjects = {}
            end
        end)
        
        createToggle(espTab, "Line of Sight", config.LineOfSight, function(state)
            config.LineOfSight = state
        end).Position = UDim2.new(0, 10, 0, 40)
        
        createToggle(espTab, "Simple Lines", config.SimpleLines, function(state)
            config.SimpleLines = state
        end).Position = UDim2.new(0, 10, 0, 80)
        
        gui.Tabs["ESP"] = espTab
        
        -- Onglet TP
        local tpTab = Instance.new("Frame")
        tpTab.Size = UDim2.new(1, 0, 1, 0)
        tpTab.BackgroundTransparency = 1
        tpTab.Visible = gui.ActiveTab == "TP"
        tpTab.Parent = contentFrame
        
        createToggle(tpTab, "TP Behind", config.TpBehind, function(state)
            config.TpBehind = state
        end)
        
        createToggle(tpTab, "Auto TP Hors Map", config.AutoTP, function(state)
            config.AutoTP = state
        end).Position = UDim2.new(0, 10, 0.025, 40)
        
        createToggle(tpTab, "Clique TP", config.ClickTP, function(state)
            config.ClickTP = state
        end).Position = UDim2.new(0, 10, 0.025, 80)
        
        local playerList = Instance.new("ScrollingFrame")
        playerList.Size = UDim2.new(1, -10, 0.5, 0)
        playerList.Position = UDim2.new(0, 5, 0, 120)
        playerList.BackgroundTransparency = 1
        playerList.Parent = tpTab
        
        local function updatePlayerList()
            playerList:ClearAllChildren()
            
            local yPos = 5
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local playerBtn = createButton(playerList, UDim2.new(1, -10, 0, 30), 
                        UDim2.new(0, 5, 0, yPos), player.Name, accentColor, textColor)

                    playerBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                                sendNotification("TP", "Téléporté vers " .. player.Name, 3, image)
                            end
                            return Enum.ContextActionResult.Sink
                        end
                    end)
                    
                    yPos += 35
                end
            end
            playerList.CanvasSize = UDim2.new(0, 0, 0, yPos)
        end
        
        local refreshBtn = createButton(tpTab, UDim2.new(1, -20, 0, 30), 
            UDim2.new(0, 5, 0.070, 60), "Actualiser la liste", accentColor, textColor)
        
        refreshBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updatePlayerList()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        updatePlayerList()
        gui.Tabs["TP"] = tpTab
        
        -- Onglet Health
        local healthTab = Instance.new("Frame")
        healthTab.Size = UDim2.new(1, 0, 1, 0)
        healthTab.BackgroundTransparency = 1
        healthTab.Visible = gui.ActiveTab == "Health"
        healthTab.Parent = contentFrame
        
        createToggle(healthTab, "God Mode", config.GodMode, function(state)
            config.GodMode = state
            enforceGodMode(LocalPlayer.Character)
        end)
        
        createSlider(healthTab, "Points de Vie", 1, 500, config.HealthValue, function(value)
            config.HealthValue = value
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = value
            end
        end).Position = UDim2.new(0, 10, 0.025, 40)
        
        gui.Tabs["Health"] = healthTab
        
        -- Onglet Speed
        local speedTab = Instance.new("Frame")
        speedTab.Size = UDim2.new(1, 0, 1, 0)
        speedTab.BackgroundTransparency = 1
        speedTab.Visible = gui.ActiveTab == "Speed"
        speedTab.Parent = contentFrame
        
        createToggle(speedTab, "Speed Boost", config.SpeedBoost, function(state)
            config.SpeedBoost = state
            updateSpeed()
        end)
        
        createSlider(speedTab, "Vitesse", 16, 300, config.CurrentSpeed, function(value)
            config.CurrentSpeed = value
            if config.SpeedBoost then
                updateSpeed()
            end
        end).Position = UDim2.new(0, 10, 0.025, 40)
        
        gui.Tabs["Speed"] = speedTab
        
        -- Onglet Theme
        local themeTab = Instance.new("Frame")
        themeTab.Size = UDim2.new(1, 0, 1, 0)
        themeTab.BackgroundTransparency = 1
        themeTab.Visible = gui.ActiveTab == "Theme"
        themeTab.Parent = contentFrame
        
        local yPos = 10
        for themeName, colors in pairs(themeColors) do
            local themeBtn = createButton(themeTab, UDim2.new(1, -20, 0, 30), 
                UDim2.new(0, 10, 0, yPos), themeName, colors.main, textColor)
            
            themeBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    config.CurrentTheme = themeName
                    mainColor = colors.main
                    accentColor = colors.accent
                    createWindow()
                    return Enum.ContextActionResult.Sink
                end
            end)
            
            yPos += 40
        end
        
        gui.Tabs["Theme"] = themeTab
        
        -- Onglet Divers
        local diversTab = Instance.new("Frame")
        diversTab.Size = UDim2.new(1, 0, 1, 0)
        diversTab.BackgroundTransparency = 1
        diversTab.Visible = gui.ActiveTab == "Divers"
        diversTab.Parent = contentFrame
        
        local positionBtn = createButton(diversTab, UDim2.new(1, -20, 0, 30), 
            UDim2.new(0, 10, 0, 10), "Get Position", accentColor, textColor)
        
        local positionBox = createTextBox(diversTab, UDim2.new(1, -20, 0, 80), 
            UDim2.new(0, 10, 0, 50), "", "X Y Z")
        positionBox.TextEditable = true
        
        positionBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = getPlayerPosition()
                positionBox.Text = string.format("%.2f %.2f %.2f", pos.X, pos.Y, pos.Z)
                return Enum.ContextActionResult.Sink
            end
        end)
        
        local tpPositionBtn = createButton(diversTab, UDim2.new(1, -20, 0, 30), 
            UDim2.new(0, 10, 0, 140), "Tp To Position", accentColor, textColor)
        
        tpPositionBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local text = positionBox.Text
                local numbers = {}
                for num in text:gmatch("[%d%.%-]+") do
                    table.insert(numbers, tonumber(num))
                end
                if #numbers >= 3 then
                    local pos = Vector3.new(numbers[1], numbers[2], numbers[3])
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
                    end
                else
                    sendNotification("Erreur", "Format invalide. Utilisez: X Y Z", 3, image)
                end
                return Enum.ContextActionResult.Sink
            end
        end)
        
        local autoJumpToggle = createButton(diversTab, UDim2.new(1, -20, 0, 30), 
            UDim2.new(0, 10, 0, 180), "AutoJump: " .. (config.AutoJump and "ON" or "OFF"), accentColor, textColor)
        
        autoJumpToggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                config.AutoJump = not config.AutoJump
                autoJumpToggle:FindFirstChildOfClass("TextLabel").Text = "AutoJump: " .. (config.AutoJump and "ON" or "OFF")
                sendNotification("AutoJump", config.AutoJump and "Activé" or "Désactivé", 3, image)
                return Enum.ContextActionResult.Sink
            end
        end)
        
        local autoWinBtn = createButton(diversTab, UDim2.new(1, -20, 0, 30), 
            UDim2.new(0, 10, 0, 220), "AutoWin", accentColor, textColor)
        
        autoWinBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                config.AutoWin = true
                sendNotification("AutoWin", "Victoire forcée activée", 3, image)
                return Enum.ContextActionResult.Sink
            end
        end)
        
        gui.Tabs["Divers"] = diversTab
        
        -- Onglet GIVE
        local giveTab = Instance.new("Frame")
        giveTab.Size = UDim2.new(1, 0, 1, 0)
        giveTab.BackgroundTransparency = 1
        giveTab.Visible = gui.ActiveTab == "GIVE"
        giveTab.Parent = contentFrame
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -10, 0.8, 0)
        scrollFrame.Position = UDim2.new(0, 5, 0, 5)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Parent = giveTab
        
        local function populateItemList()
            scrollFrame:ClearAllChildren()
            
            local items = fetchGameItems()
            local yPos = 5
            
            for i, item in ipairs(items) do
                local itemBtn = createButton(scrollFrame, UDim2.new(1, -10, 0, 25), 
                    UDim2.new(0, 5, 0, yPos), item.Name, accentColor, textColor)
                
                itemBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        giveItem(item)
                        return Enum.ContextActionResult.Sink
                    end
                end)
                
                yPos += 30
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
        end
        
        local refreshBtn = createButton(giveTab, UDim2.new(1, -20, 0, 30), 
            UDim2.new(0, 10, 0.85, 0), "Actualiser la liste", accentColor, textColor)
        
        refreshBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                populateItemList()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        populateItemList()
        gui.Tabs["GIVE"] = giveTab
        
        -- Onglet Dalgona
        local dalgonaTab = Instance.new("Frame")
        dalgonaTab.Size = UDim2.new(1, 0, 1, 0)
        dalgonaTab.BackgroundTransparency = 1
        dalgonaTab.Visible = gui.ActiveTab == "Dalgona"
        dalgonaTab.Parent = contentFrame
        
        local recordBtn = createButton(dalgonaTab, UDim2.new(0.45, -5, 0, 30), 
            UDim2.new(0, 5, 0, 10), "Enregistrer", accentColor, textColor)
        
        local stopBtn = createButton(dalgonaTab, UDim2.new(0.45, -5, 0, 30), 
            UDim2.new(0.55, 0, 0, 10), "Arrêter", accentColor, textColor)
        
        local playBtn = createButton(dalgonaTab, UDim2.new(0.45, -5, 0, 30), 
            UDim2.new(0, 5, 0, 50), "Jouer", accentColor, textColor)
        
        local clearBtn = createButton(dalgonaTab, UDim2.new(0.45, -5, 0, 30), 
            UDim2.new(0.55, 0, 0, 50), "Effacer", accentColor, textColor)
        
        local macroBox = createTextBox(dalgonaTab, UDim2.new(1, -20, 0, 120), 
            UDim2.new(0, 10, 0, 90), "", "Script macro apparaîtra ici")
        
        local shapeBox = createTextBox(dalgonaTab, UDim2.new(1, -20, 0, 30), 
            UDim2.new(0, 10, 0, 220), "", "Sélectionnez une forme")
        shapeBox.TextEditable = false
        
        local shapeButtons = {}
        local yPos = 260
        for shapeName in pairs(dalgonaShapes) do
            local shapeBtn = createButton(dalgonaTab, UDim2.new(0.3, -5, 0, 25), 
                UDim2.new(0, 10 + ((#shapeButtons % 3) * 130), 0, yPos), shapeName, accentColor, textColor)
            
            shapeBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if loadShape(shapeName) then
                        shapeBox.Text = "Forme: " .. shapeName
                        macroBox.Text = generateMacroScript()
                    end
                    return Enum.ContextActionResult.Sink
                end
            end)
            
            table.insert(shapeButtons, shapeBtn)
            
            if #shapeButtons % 3 == 0 then
                yPos += 35
            end
        end
        
        local delaySlider = createSlider(dalgonaTab, "Vitesse Macro", 0.001, 0.1, config.MacroDelay, function(value)
            config.MacroDelay = value
        end)
        delaySlider.Position = UDim2.new(0, 10, 0, 320)
        
        recordBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                startRecording()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        stopBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                stopRecording()
                macroBox.Text = generateMacroScript()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        playBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                playMacro()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        clearBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                recordedPoints = {}
                macroBox.Text = ""
                shapeBox.Text = ""
                return Enum.ContextActionResult.Sink
            end
        end)
        
        gui.Tabs["Dalgona"] = dalgonaTab
        
        -- Onglet Hitbox
        local hitboxTab = Instance.new("Frame")
        hitboxTab.Size = UDim2.new(1, 0, 1, 0)
        hitboxTab.BackgroundTransparency = 1
        hitboxTab.Visible = gui.ActiveTab == "Hitbox"
        hitboxTab.Parent = contentFrame
        
        createToggle(hitboxTab, "Hitbox Expander", config.HitboxExpander, function(state)
            config.HitboxExpander = state
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if state then
                        increaseAndShowHitbox(player.Character)
                    else
                        restoreOriginalHitbox(player.Character)
                    end
                end
            end
        end)
        
        createSlider(hitboxTab, "Hitbox Size", 1.0, 100.0, config.HitboxSize, function(value)
            config.HitboxSize = value
            if config.HitboxExpander then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        restoreOriginalHitbox(player.Character)
                        increaseAndShowHitbox(player.Character)
                    end
                end
            end
        end).Position = UDim2.new(0, 10, 0.025, 40)
        
        gui.Tabs["Hitbox"] = hitboxTab
        
        -- Onglet Fly
        local flyTab = Instance.new("Frame")
        flyTab.Size = UDim2.new(1, 0, 1, 0)
        flyTab.BackgroundTransparency = 1
        flyTab.Visible = gui.ActiveTab == "Fly"
        flyTab.Parent = contentFrame
        
        createToggle(flyTab, "Activer Fly", config.FlyEnabled, function(state)
            config.FlyEnabled = state
            if state then
                enableFly()
            else
                disableFly()
            end
        end)
        
        createSlider(flyTab, "Vitesse Fly", 1, 200, config.FlySpeed, function(value)
            config.FlySpeed = value
            if flyBodyVelocity then
                flyBodyVelocity.MaxForce = Vector3.new(value * 100, value * 100, value * 100)
            end
        end).Position = UDim2.new(0, 10, 0, 40)
        
        createSlider(flyTab, "Vitesse Verticale", 1, 100, config.FlyVerticalSpeed, function(value)
            config.FlyVerticalSpeed = value
        end).Position = UDim2.new(0, 10, 0, 100)
        
        gui.Tabs["Fly"] = flyTab
        
        -- Onglet NoClip
        local noclipTab = Instance.new("Frame")
        noclipTab.Size = UDim2.new(1, 0, 1, 0)
        noclipTab.BackgroundTransparency = 1
        noclipTab.Visible = gui.ActiveTab == "NoClip"
        noclipTab.Parent = contentFrame
        
        createToggle(noclipTab, "Activer NoClip", config.NoClip, function(state)
            config.NoClip = state
            setupNoClip()
        end)
        
        local noclipTypeLabel = Instance.new("TextLabel")
        noclipTypeLabel.Text = "Type de NoClip:"
        noclipTypeLabel.TextColor3 = textColor
        noclipTypeLabel.BackgroundTransparency = 1
        noclipTypeLabel.Size = UDim2.new(1, 0, 0, 20)
        noclipTypeLabel.Position = UDim2.new(0, 10, 0, 40)
        noclipTypeLabel.Font = Enum.Font.Gotham
        noclipTypeLabel.TextSize = 12
        noclipTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
        noclipTypeLabel.Parent = noclipTab
        
        local noclipTypeClassic = createButton(noclipTab, UDim2.new(0.45, -5, 0, 25), 
            UDim2.new(0, 10, 0, 70), "Classic", 
            config.NoClipType == "Classic" and accentColor or Color3.fromRGB(70,70,70), 
            textColor)
        
        local noclipTypeGhost = createButton(noclipTab, UDim2.new(0.45, -5, 0, 25), 
            UDim2.new(0.55, 0, 0, 70), "Ghost", 
            config.NoClipType == "Ghost" and accentColor or Color3.fromRGB(70,70,70), 
            textColor)
        
        noclipTypeClassic.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                config.NoClipType = "Classic"
                noclipTypeClassic.BackgroundColor3 = accentColor
                noclipTypeGhost.BackgroundColor3 = Color3.fromRGB(70,70,70)
                setupNoClip()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        noclipTypeGhost.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                config.NoClipType = "Ghost"
                noclipTypeGhost.BackgroundColor3 = accentColor
                noclipTypeClassic.BackgroundColor3 = Color3.fromRGB(70,70,70)
                setupNoClip()
                return Enum.ContextActionResult.Sink
            end
        end)
        
        createSlider(noclipTab, "NoClip Force", 0.1, 5, config.NoClipForce, function(value)
            config.NoClipForce = value
        end).Position = UDim2.new(0, 10, 0, 110)
        
        gui.Tabs["NoClip"] = noclipTab
        
        gui.MainFrame.Size = UDim2.new(0, 10, 0, 10)
        gui.MainFrame.Position = UDim2.new(0.5, -5, 0.5, -5)
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local sizeTween = TweenService:Create(gui.MainFrame, tweenInfo, {
            Size = UDim2.new(0, 400, 0, 500),
            Position = UDim2.new(0.5, -200, 0.5, -250)
        })
        sizeTween:Play()
        
        sendNotification("Script", "Menu cheat chargé avec succès", 5, image)
    end)
end

-- Boucles principales
RunService.RenderStepped:Connect(function()
    pcall(function()
        if config.ESP or config.LineOfSight or config.SimpleLines then
            updateESP()
        end
    end)
    
    pcall(function()
        if config.AimbotHumain and mouseLocked then
            if not fovCircle then
                initAimbot()
            end
            
            local mousePos = UserInputService:GetMouseLocation()
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            fovCircle.Position = center
            fovCircle.Visible = true
            
            if not currentTarget or not isTargetValid(currentTarget) then
                currentTarget = getClosestTarget()
            end
            
            if currentTarget and currentTarget.Character then
                local part = getAimPart(currentTarget.Character)
                if part then
                    moveCameraSmooth(part.Position)
                    
                    nameDisplay.Text = "[Ciblé] " .. currentTarget.Name
                    nameDisplay.Position = Vector2.new(center.X, center.Y - fovCircle.Radius - 22)
                    nameDisplay.Visible = true
                    
                    local camDir = Camera.CFrame.LookVector
                    local toTarget = (part.Position - Camera.CFrame.Position).Unit
                    local aligned = camDir:Dot(toTarget) > 0.995
                    
                    if aligned and config.AutoShoot and tick() - lastShotTime >= config.AimbotCooldown then
                        startShooting()
                        lastShotTime = tick()
                    else
                        stopShooting()
                    end
                else
                    nameDisplay.Visible = false
                    stopShooting()
                end
            else
                nameDisplay.Visible = false
                stopShooting()
            end
        elseif fovCircle and config.AimbotHumain == false then
            fovCircle.Visible = false
            nameDisplay.Visible = false
            stopShooting()
        end
    end)
    
    pcall(function()
        if config.AimbotFast and mouseLocked then
            if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Head") then
                currentTarget = getClosestVisibleEnemy()
            end
            
            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
                local head = currentTarget.Character:FindFirstChild("Head")
                local humanoid = currentTarget.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 and isVisibleFast(head) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                    startShooting()
                else
                    currentTarget = nil
                    stopShooting()
                end
            else
                stopShooting()
            end
        end
    end)
    
    pcall(function()
        if config.TpBehind then
            local target = nil
            if tpBehindCurrentTarget then
                if not tpBehindCurrentTarget.Character or not tpBehindCurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
                    tpBehindCurrentTarget = nil
                else
                    local targetHumanoid = tpBehindCurrentTarget.Character:FindFirstChildOfClass("Humanoid")
                    local targetHRP = tpBehindCurrentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if not targetHumanoid or targetHumanoid.Health <= 0 or targetHRP.Position.Y < -50 then
                        tpBehindCurrentTarget = nil
                    else
                        target = tpBehindCurrentTarget
                    end
                end
            end
            
            if not target then
                target = getClosestEnemy()
                tpBehindCurrentTarget = target
            end
            
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = target.Character.HumanoidRootPart
                local behindPos = targetHRP.Position - (targetHRP.CFrame.LookVector * tpBehindOffset)
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(behindPos, targetHRP.Position)
                end
            end
        end
    end)
    
    pcall(function()
        if config.AutoTP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if hrp.Position.Y < -50 then
                local farthestPlayer = getFarthestPlayer()
                if farthestPlayer and farthestPlayer.Character and farthestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local farthestHRP = farthestPlayer.Character.HumanoidRootPart
                    hrp.CFrame = farthestHRP.CFrame * CFrame.new(0, 5, 0)
                    sendNotification("Script", "TP vers le joueur le plus éloigné", 3, image)
                end
            end
        end
    end)
    
    pcall(function()
        if config.InfiniteAmmo then
            infiniteBullet()
        end
    end)
    
    pcall(autoJump)
end)

-- Gestion des touches
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Comma then
        toggleMouseLock()
    end
    
    if input.KeyCode == Enum.KeyCode.Semicolon then
        toggleMenu()
    end
    
    if input.KeyCode == Enum.KeyCode.P and CanRespawnToCheckpoint then
        CanRespawnToCheckpoint = false
        local revived = tryReviveCharacter()
        if not revived then
            LocalPlayer.CharacterAdded:Wait()
            wait(0.5)
        end
        teleportToCheckpoint()
        sendNotification("Script", "Respawn au checkpoint effectué.", 5, image)
    end
    
    if config.RecordingPoints and input.UserInputType == Enum.UserInputType.MouseButton1 then
        table.insert(recordedPoints, UserInputService:GetMouseLocation())
    end
    
    handleClickTeleport(input, gameProcessed)
end)

-- Initialisation des joueurs pour l'ESP
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
    if config.HitboxExpander then
        handlePlayer(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        espObjects[player].box:Remove()
        espObjects[player].name:Remove()
        if espObjects[player].line then
            espObjects[player].line:Remove()
        end
        espObjects[player] = nil
    end
end)

-- Initialisation du système de checkpoint
if LocalPlayer.Character then
    setCheckpointFromCharacter(LocalPlayer.Character)
    onCharacterAdded(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    onCharacterAdded(char)
    setupNoClip()
end)

-- Attendre que le joueur soit chargé
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Initialisation du script
createWindow()

-- Mise à jour initiale
if LocalPlayer.Character then
    enforceGodMode(LocalPlayer.Character)
    updateSpeed()
    setupNoClip()
end

-- Initialisation de l'aimbot après un court délai
delay(1, function()
    if config.AimbotHumain then
        initAimbot()
    end
end)
