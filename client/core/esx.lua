if Config.Core == "ESX" then
    xCore = {}
    local ESX = exports["es_extended"]:getSharedObject()
    local ox_inventory = exports.ox_inventory

    xCore.GetPlayerData = function()
        local ply = ESX.GetPlayerData()
        if not ply then return nil end
        return {
            citizenid = ply.identifier
        }
    end

    xCore.Notify = function(msg, typ, time)
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = false,
            args = {"PHONE", msg}
        })
    end

    xCore.HasItemByName = function(item)
        local count = ox_inventory:Search('count', item)
        return count and count > 0
    end

    xCore.GetPhoneItem = function()
        local items = ox_inventory:Search('slots', 'phone')
        if items and items[1] then
            return items[1]
        end
        return nil
    end

    xCore.GetPhoneItem = function()
        local items = ox_inventory:Search('slots', 'phone')
        if items and items[1] then
            return items[1]
        end
        return nil
    end

    xCore.GetClosestPlayer = function ()
        return ESX.Game.GetClosestPlayer()
    end
end