lib.callback.register('z-phone:server:GetEmails', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end
    
    local phone_number = phoneItem.metadata.phone_number
    local query = [[
        SELECT 
            id,
            institution,
            phone_number as citizenid,
            subject,
            content,
            is_read,
            DATE_FORMAT(created_at, '%d %b %Y %H:%i') as created_at
        FROM zp_emails WHERE phone_number = ? ORDER BY id DESC LIMIT 100
    ]]
    local result = MySQL.query.await(query, {phone_number})

    if not result then
        return {}
    end

    return result
end)