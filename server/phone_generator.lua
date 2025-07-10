-- Script pour générer des téléphones avec numéros uniques

local function GeneratePhoneNumber()
    return math.random(81, 89) .. math.random(100000, 999999)
end

local function IsPhoneNumberExists(phone_number)
    local result = MySQL.scalar.await('SELECT COUNT(*) FROM zp_users WHERE phone_number = ?', {phone_number})
    return result and result > 0
end

local function GetUniquePhoneNumber()
    local phone_number
    repeat
        phone_number = GeneratePhoneNumber()
    until not IsPhoneNumberExists(phone_number)
    return phone_number
end

-- Commande pour créer un téléphone avec numéro unique
RegisterCommand('createphone', function(source, args)
    local Player = xCore.GetPlayerBySource(source)
    if not Player then return end
    
    local phone_number = GetUniquePhoneNumber()
    
    -- Ajouter le téléphone avec métadonnées
    local success = exports.ox_inventory:AddItem(source, 'phone', 1, {
        phone_number = phone_number,
        description = 'Numéro: ' .. phone_number
    })
    
    if success then
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 0},
            multiline = false,
            args = {"PHONE", "Téléphone créé avec le numéro: " .. phone_number}
        })
    end
end, true) -- true = admin only

-- Event pour ox_inventory quand un téléphone est utilisé
exports('phone_metadata', function(source, item, metadata)
    if not metadata.phone_number then
        local phone_number = GetUniquePhoneNumber()
        return {
            phone_number = phone_number,
            description = 'Numéro: ' .. phone_number
        }
    end
    return metadata
end)