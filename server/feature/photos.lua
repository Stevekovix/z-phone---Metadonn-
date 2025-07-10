lib.callback.register('z-phone:server:GetPhotos', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local query = [[
            select 
                zpp.id,
                zpp.media as photo,
                DATE_FORMAT(zpp.created_at, '%d/%m/%Y %H:%i') as created_at
            from zp_photos zpp
            WHERE zpp.phone_number = ? ORDER BY zpp.id DESC
        ]]

        local result = MySQL.query.await(query, {
            phone_number
        })

        if result then
            return result
        else
            return {}
        end
    end
    return {}
end)

lib.callback.register('z-phone:server:SavePhotos', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local query = "INSERT INTO zp_photos (phone_number, media, location) VALUES (?, ?, ?)"

        local id = MySQL.insert.await(query, {
            phone_number,
            body.url,
            body.location,
        })

        if id then
            return true
        else
            return false
        end
    end
    return false
end)

lib.callback.register('z-phone:server:DeletePhotos', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local query = "DELETE from zp_photos WHERE id = ? AND phone_number = ?"

        MySQL.query.await(query, {
            body.id,
            phone_number,
        })

        return true
    end
    return false
end)