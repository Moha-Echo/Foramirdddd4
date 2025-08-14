local StarterGui = game:GetService("StarterGui")
local image = "rbxassetid://111201744721013"

-- Fonction de notification améliorée
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
    sendNotification("Chargement", "Le script est déjà en cours de chargement", 5)
    return
end

pcall(function() getgenv().jumpscare_jeffwuz_loaded = true end)

-- Configuration
getgenv().Notify = true
local Notify_Webhook = "https://discord.com/api/webhooks/1318631563327442965/UzaxWNnecnoZOzloQxxAuBZ0xdfxcw8eUi9jgygm1FZoh_qn7tAa-N9EzpMi5iUmSkXF"

-- Vérification des fonctions nécessaires
if not game:GetService("HttpService") then
    sendNotification("Erreur Critique", "HttpService non disponible", 10)
    return
end

-- Initialisation
local player = game:GetService("Players").LocalPlayer
local HttpService = game:GetService('HttpService')

-- Fonction pour tronquer les textes trop longs pour Discord
local function truncate(text, limit)
    if not text then return "" end
    if #text > limit then
        return text:sub(1, limit - 3) .. "..."
    end
    return text
end

-- Fonction de notification via webhook
function notify_hook()
    -- Vérification du webhook
    if Notify_Webhook == "" or Notify_Webhook == "TON_WEBHOOK_ICI" then
        sendNotification("Webhook", "Webhook non configuré", 5)
        return false
    end

    sendNotification("Notification", "Envoi des données à Discord...", 3)
    
    -- Récupération des données du joueur
    local thumbnailUrl = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
    local descriptionData = "Non disponible"
    local createdData = "Non disponible"

    -- Récupération des données avec gestion des erreurs
    pcall(function()
        -- API Thumbnail
        pcall(function()
            local ThumbnailAPI = game:HttpGet("https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds="..player.UserId.."&size=420x420&format=Png&isCircular=true")
            local json = HttpService:JSONDecode(ThumbnailAPI)
            thumbnailUrl = json.data[1].imageUrl
        end)

        -- API User Info
        pcall(function()
            local UserAPI = game:HttpGet("https://users.roproxy.com/v1/users/"..player.UserId)
            local json = HttpService:JSONDecode(UserAPI)
            descriptionData = json.description or "Aucune description"
            createdData = json.created or os.date("%Y-%m-%d")
        end)
    end)

    -- Formatage des données pour l'embed
    local createdDate = "Non disponible"
    if type(createdData) == "string" then
        createdDate = string.match(createdData, "^([%d-]+)") or createdData
    end

    -- Construction de l'embed avec vérification des données
    local send_data = {
        ["username"] = "Jumpscare Notify",
        ["avatar_url"] = "https://static.wikia.nocookie.net/19dbe80e-0ae6-48c7-98c7-3c32a39b2d7c/scale-to-width/370",
        ["content"] = "Jeff Wuz Here !",
        ["embeds"] = {{
            ["title"] = "Jeff's Log",
            ["description"] = "**Game:** [Lien du jeu](https://www.roblox.com/games/"..game.PlaceId..")\n\n"..
                            "**Profile:** [Profil du joueur](https://www.roblox.com/users/"..player.UserId.."/profile)\n\n"..
                            "**Job ID:** "..game.JobId,
            ["color"] = 16711680,  -- Rouge en décimal
            ["fields"] = {
                {
                    ["name"] = "Username",
                    ["value"] = truncate(player.Name, 256),
                    ["inline"] = true
                },
                {
                    ["name"] = "Display Name",
                    ["value"] = truncate(player.DisplayName, 256),
                    ["inline"] = true
                },
                {
                    ["name"] = "User ID",
                    ["value"] = tostring(player.UserId),
                    ["inline"] = true
                },
                {
                    ["name"] = "Account Age",
                    ["value"] = player.AccountAge.." jours",
                    ["inline"] = true
                },
                {
                    ["name"] = "Membership",
                    ["value"] = player.MembershipType.Name,
                    ["inline"] = true
                },
                {
                    ["name"] = "Account Created",
                    ["value"] = truncate(createdDate, 100),
                    ["inline"] = true
                },
                {
                    ["name"] = "Profile Description",
                    ["value"] = "```\n"..truncate(descriptionData, 1000).."\n```",
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "JTK Log - "..os.date("%d/%m/%Y %H:%M"),
                ["icon_url"] = "https://miro.medium.com/v2/resize:fit:1280/0*c6-eGC3Dd_3HoF-B"
            },
            ["thumbnail"] = {
                ["url"] = thumbnailUrl
            },
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }

    -- Envoi du webhook avec gestion des erreurs - SOLUTION FONCTIONNELLE
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

    if success then
        sendNotification("Succès", "Données envoyées à Discord!", 5)
        return true
    else
        local errMsg = tostring(response)
        sendNotification("Erreur Webhook", "Échec d'envoi: "..errMsg, 10)
        return false
    end
end

-- Exécution de la notification si activée
if getgenv().Notify == true then
    local success = notify_hook()
    if not success then
        sendNotification("Échec", "Échec de l'envoi de la notification Discord", 5)
    end
elseif getgenv().Notify ~= false then
    sendNotification("Configuration", "La valeur de Notify doit être true ou false", 5)
end
