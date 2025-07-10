lib.callback.register('z-phone:server:GetContacts', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local query = [[
            select 
                zpc.contact_name as name,
                DATE_FORMAT(zpc.created_at, '%d/%m/%Y %H:%i') as add_at,
                zpc.contact_phone_number as contact_citizenid,
                COALESCE(zpu.avatar, 'https://i.ibb.co.com/F3w0F5L/default-avatar-1.png') as avatar,
                zpc.contact_phone_number as phone_number
            from zp_contacts zpc
            LEFT JOIN zp_users zpu ON zpu.phone_number = zpc.contact_phone_number
            WHERE zpc.phone_number = ? ORDER BY zpc.contact_name ASC
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

lib.callback.register('z-phone:server:DeleteContact', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local query = [[
            DELETE FROM zp_contacts WHERE phone_number = ? and contact_phone_number = ?
        ]]

        MySQL.query.await(query, {
            phone_number,
            body.contact_citizenid
        })

        TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
            type = "Notification",
            from = "Contact",
            message = "Success delete contact!"
        })
        return true
    end
    return false
end)

lib.callback.register('z-phone:server:UpdateContact', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local query = [[
            UPDATE zp_contacts SET contact_name = ? WHERE contact_phone_number = ? AND phone_number = ?
        ]]

        MySQL.update.await(query, {
            body.name,
            body.contact_citizenid,
            phone_number
        })
        
        TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
            type = "Notification",
            from = "Contact",
            message = "Success update contact!"
        })
        return true
    end
    return false
end)

lib.callback.register('z-phone:server:SaveContact', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local queryCheckDuplicate = [[
            select zpc.* from zp_contacts zpc WHERE zpc.contact_phone_number = ? and zpc.phone_number = ? LIMIT 1
        ]]
        local isDuplicate = MySQL.single.await(queryCheckDuplicate, {
            body.phone_number,
            phone_number
        })

        if isDuplicate then
            TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
                type = "Notification",
                from = "Contact",
                message = "Duplicate contact (".. isDuplicate.contact_name ..")!"
            })
            return false
        end

        local queryInsert = "INSERT INTO zp_contacts (phone_number, contact_phone_number, contact_name) VALUES (?, ?, ?)"
        local contactId = MySQL.insert.await(queryInsert, {
            phone_number,
            body.phone_number,
            body.name
        })
        
        if body.request_id ~= 0 then
            MySQL.query.await("DELETE FROM zp_contacts_requests WHERE id = ?", { body.request_id })
        end

        TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
            type = "Notification",
            from = "Contact",
            message = "Success save contact!"
        })
        return true
    end
    return false
end)

lib.callback.register('z-phone:server:GetContactRequest', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if not Player or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end

    local phone_number = phoneItem.metadata.phone_number
    local query = [[
        SELECT 
            zpcr.id,
            zpu.avatar,
            zpu.phone_number AS name,
            DATE_FORMAT(zpcr.created_at, '%d %b %Y %H:%i') as request_at
        FROM zp_contacts_requests zpcr
        LEFT JOIN zp_users zpu ON zpu.phone_number = zpcr.from_phone_number
        WHERE zpcr.phone_number = ? ORDER BY zpcr.id DESC
    ]]

    local requests = MySQL.query.await(query, {
        phone_number
    })
    
    if not requests then
        requests = {}
    end

    return requests
end)

lib.callback.register('z-phone:server:ShareContact', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if not Player or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end

    local TargetPlayer = xCore.GetPlayerBySource(body.to_source)
    local targetPhoneItem = xCore.GetPhoneItem(body.to_source)
    if not TargetPlayer or not targetPhoneItem or not targetPhoneItem.metadata or not targetPhoneItem.metadata.phone_number then return false end

    local phone_number = phoneItem.metadata.phone_number
    local target_phone_number = targetPhoneItem.metadata.phone_number
    local query = "INSERT INTO zp_contacts_requests (phone_number, from_phone_number) VALUES (?, ?)"
    MySQL.insert.await(query, {
        target_phone_number,
        phone_number,
    })

    TriggerClientEvent("z-phone:client:sendNotifInternal", body.to_source, {
        type = "Notification",
        from = "Contact",
        message = "New contact request received!"
    })
    return true
end)


lib.callback.register('z-phone:server:DeleteContactRequest', function(source, body)
    MySQL.query.await("DELETE FROM zp_contacts_requests WHERE id = ?", { body.id })
    return true
end)
