lib.callback.register('z-phone:server:GetAds', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return end

    local phone_number = phoneItem.metadata.phone_number
    local playerName = Player.name

    local query = [[
        select 
            zpa.content,
            zpa.media,
            zpa.phone_number as citizenid,
            DATE_FORMAT(zpa.created_at, '%d/%m/%Y %H:%i') as time,
            COALESCE(zpu.avatar, 'https://i.ibb.co.com/F3w0F5L/default-avatar-1.png') as avatar,
            zpa.phone_number,
            COALESCE(zpu.name, zpa.phone_number) as name
        from zp_ads zpa
        LEFT JOIN zp_users zpu ON zpu.phone_number = zpa.phone_number
        ORDER BY zpa.id DESC
        LIMIT 100
    ]]

    local result = MySQL.query.await(query)
    if not result then
        return {}
    end
    
    return result
end)

lib.callback.register('z-phone:server:SendAds', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)

    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return end
    local phone_number = phoneItem.metadata.phone_number
    local query = "INSERT INTO zp_ads (phone_number, media, content) VALUES (?, ?, ?)"

    local id = MySQL.insert.await(query, {
        phone_number,
        body.media,
        body.content,
    })

    if not  id then
        return false
    end
     
    TriggerClientEvent("z-phone:client:sendNotifInternal", -1, {
        type = "Notification",
        from = "Ads",
        message = "New ads posted!"
    })
    return true
end)