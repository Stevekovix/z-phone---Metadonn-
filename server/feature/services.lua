lib.callback.register('z-phone:server:GetServices', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end

    local job = Player.job
    local phone_number = phoneItem.metadata.phone_number
    local query = [[
        SELECT 
            zpsm.phone_number,
            zpsm.id,
            zpsm.phone_number as citizenid,
            zpsm.message,
            DATE_FORMAT(zpsm.created_at, '%d/%m/%Y %H:%i') as created_at
        FROM zp_service_messages zpsm 
        WHERE zpsm.service = ? AND zpsm.solved_by_phone_number IS NULL
        ORDER BY id DESC LIMIT 100
    ]]
    local result = MySQL.query.await(query, { job.name })

    if not result then
        return {}
    end

    return result
end)


lib.callback.register('z-phone:server:SendMessageService', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end
    
    local phone_number = phoneItem.metadata.phone_number
    local query = "INSERT INTO zp_service_messages (phone_number, message, service) VALUES (?, ?, ?)"

    local id = MySQL.insert.await(query, {
        phone_number,
        body.message,
        body.job,
    })

    if not id then
        return false
    end
    
    TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
        type = "Notification",
        from = "Services",
        message = "Message sended!"
    })
    return true
end)

lib.callback.register('z-phone:server:SolvedMessageService', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end

    local phone_number = phoneItem.metadata.phone_number
    MySQL.update.await('UPDATE zp_service_messages SET solved_by_phone_number = ?, solved_reason = ? WHERE id = ?', {
        phone_number,
        body.reason, 
        body.id,
    })
    
    TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
        type = "Notification",
        from = "Services",
        message = "Message service solved!"
    })

    return true
end)