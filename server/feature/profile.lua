lib.callback.register('z-phone:server:GetProfile', function(source)
    local Player = xCore.GetPlayerBySource(source)
    if Player == nil then return nil end

    local phoneItem = xCore.GetPhoneItem(source)
    if not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then
        return nil
    end

    local phone_number = phoneItem.metadata.phone_number
    local citizenid = Player.citizenid
    local query = [[
        select 
            zpu.name,
            zpu.citizenid,
            zpu.phone_number,
            zpu.created_at,
            zpu.last_seen,
            zpu.avatar,
            zpu.unread_message_service,
            zpu.unread_message,
            zpu.wallpaper,
            zpu.is_anonim,
            zpu.is_donot_disturb,
            zpu.frame,
            zpu.iban,
            zpu.active_loops_userid,
            zpu.inetmax_balance,
            zpu.phone_height
        from zp_users zpu WHERE zpu.phone_number = ? LIMIT 1
    ]]

    local result = MySQL.single.await(query, {
        phone_number
    })

    if not result then
        -- Vérifier si le citizenid existe déjà
        local existingUser = MySQL.single.await('SELECT citizenid FROM zp_users WHERE citizenid = ?', {citizenid})
        
        if not existingUser then
            local iban = math.random(7, 9)..math.random(1000000000, 9999999999)
            local queryNew = "INSERT INTO zp_users (citizenid, name, phone_number, iban, inetmax_balance) VALUES (?, ?, ?, ?, ?)"

            local id = MySQL.insert.await(queryNew, {
                citizenid,
                Player.name,
                phone_number,
                iban,
                5000000
            })
        else
            -- Mettre à jour le numéro de téléphone pour cet utilisateur existant
            MySQL.update.await('UPDATE zp_users SET phone_number = ? WHERE citizenid = ?', {
                phone_number,
                citizenid
            })
        end

        result = MySQL.single.await(query, {
            phone_number
        })
    end

    result.name = Player.name
    result.job = {}
    result.job.name = Player.job.name
    result.job.label = Player.job.label
    result.signal = Config.Signal.Zones[Config.Signal.DefaultSignalZones].ChanceSignal
    result.phone_number = phone_number
    return result
end)

lib.callback.register('z-phone:server:UpdateProfile', function(source, body)
    local affectedRows = nil
    local Player = xCore.GetPlayerBySource(source)
    if Player ~= nil then
        local phoneItem = xCore.GetPhoneItem(source)
        if not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then
            return false
        end
        
        local phone_number = phoneItem.metadata.phone_number
        if body.type == 'avatar' then
            affectedRows = MySQL.update.await('UPDATE zp_users SET avatar = ? WHERE phone_number = ?', {
                body.value, phone_number
            })
        elseif body.type == 'wallpaper' then
            affectedRows = MySQL.update.await('UPDATE zp_users SET wallpaper = ? WHERE phone_number = ?', {
                body.value, phone_number
            })
        elseif body.type == 'is_anonim' then
            affectedRows = MySQL.update.await('UPDATE zp_users SET is_anonim = ? WHERE phone_number = ?', {
                body.value, phone_number
            })
        elseif body.type == 'is_donot_disturb' then
            affectedRows = MySQL.update.await('UPDATE zp_users SET is_donot_disturb = ? WHERE phone_number = ?', {
                body.value, phone_number
            })
        elseif body.type == 'frame' then
            affectedRows = MySQL.update.await('UPDATE zp_users SET frame = ? WHERE phone_number = ?', {
                body.value, phone_number
            })
        elseif body.type == 'phone_height' then
            affectedRows = MySQL.update.await('UPDATE zp_users SET phone_height = ? WHERE phone_number = ?', {
                body.value, 
                phone_number
            })
            
        else
            lib.print.info("RETRIGER DETECTED, SHOULD BANN IF NEEDED")
        end

        if affectedRows then
            TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
                type = "Notification",
                from = "Setting",
                message = "Success updated!"
            })
            return true
        else
            return false
        end
    end

    return false
end)