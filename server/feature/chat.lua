lib.callback.register('z-phone:server:StartOrContinueChatting', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then 
        return nil 
    end

    local phone_number = phoneItem.metadata.phone_number
    local citizenid = Player.citizenid

    if body.phone_number and body.phone_number == phone_number then 
        TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
            type = "Notification",
            from = "Message",
            message = "Cannot chat to your self!"
        })
        return nil 
    end

    local target_phone_number = body.phone_number
    if not target_phone_number or target_phone_number == "" then
        return nil 
    end
    
    local queryGetConversationID = [[
        SELECT conversationid
        FROM zp_conversation_participants
        WHERE phone_number IN (?, ?)
        GROUP BY conversationid
        HAVING COUNT(DISTINCT phone_number) = 2
        AND COUNT(*) = 2
    ]]

    local conversationid = MySQL.scalar.await(queryGetConversationID, {
        phone_number,
        target_phone_number
    })
     
    if conversationid == nil then
        local queryNewConv = "INSERT INTO zp_conversations (is_group) VALUES (?)"
        conversationid = MySQL.insert.await(queryNewConv, {
            false,
        })

        local queryParticipant = "INSERT INTO zp_conversation_participants (conversationid, phone_number) VALUES (?, ?)"
        local participanOne = MySQL.insert.await(queryParticipant, {
            conversationid,
            phone_number,
        })

        local participanTwo = MySQL.insert.await(queryParticipant, {
            conversationid,
            target_phone_number,
        })
    end

    local queryChatting = [[
        SELECT
            COALESCE(from_user.avatar, 'https://i.ibb.co.com/F3w0F5L/default-avatar-1.png') as avatar,
			other_participant.phone_number as citizenid,
            CASE
                WHEN c.is_group = 0 THEN
                    COALESCE(
                        contact.contact_name,
                        other_participant.phone_number
                    )
                ELSE c.name
            END AS conversation_name,
            COALESCE(DATE_FORMAT(from_user.last_seen, '%d/%m/%Y %H:%i'), 'Unknown') as last_seen,
            0 as is_read,
            c.id as conversationid,
			c.is_group
        FROM
            zp_conversations c
        JOIN
            zp_conversation_participants p
            ON c.id = p.conversationid
        LEFT JOIN
            zp_conversation_participants other_participant
            ON c.id = other_participant.conversationid
            AND other_participant.phone_number != p.phone_number
        LEFT JOIN
            zp_users from_user
            ON other_participant.phone_number = from_user.phone_number
        LEFT JOIN
            zp_contacts contact
            ON contact.phone_number = p.phone_number
            AND contact.contact_phone_number = other_participant.phone_number
        WHERE
            c.id = ? and p.phone_number = ?
        LIMIT 1
        ]]
            
    local result = MySQL.single.await(queryChatting, {
        conversationid,
        phone_number
    })
     
    if result then 
        return result
    else
        return nil
    end
end)

lib.callback.register('z-phone:server:GetChats', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local citizenid = Player.citizenid

        MySQL.Async.execute('UPDATE zp_users SET last_seen = now() WHERE phone_number = ?', { phone_number })

        local query = [[
            WITH LatestMessages AS (
                SELECT
                    conversationid,
                    content,
                    created_at,
                    is_deleted,
                    ROW_NUMBER() OVER (PARTITION BY conversationid ORDER BY created_at DESC) AS rn
                FROM
                    zp_conversation_messages
            )
            SELECT
                COALESCE(from_user.avatar, 'https://i.ibb.co.com/F3w0F5L/default-avatar-1.png') as avatar,
				other_participant.phone_number as citizenid,
                CASE
                    WHEN c.is_group = 0 THEN
                        COALESCE(
                            contact.contact_name,
                            other_participant.phone_number
                        )
                    ELSE c.name
                END AS conversation_name,
                other_participant.phone_number,
                COALESCE(DATE_FORMAT(from_user.last_seen, '%d/%m/%Y %H:%i'), 'Unknown') as last_seen,
                0 as isRead,
				CASE
                    WHEN last_msg.is_deleted = 1 THEN
                        'This message was deleted'
                    WHEN last_msg.content = '' THEN
                        'media'
                    ELSE last_msg.content
                END AS last_message,
                DATE_FORMAT(last_msg.created_at, '%H:%i') AS last_message_time,
                c.id as conversationid,
				c.is_group
            FROM
                zp_conversations c
            JOIN
                zp_conversation_participants p
                ON c.id = p.conversationid
            LEFT JOIN
                zp_conversation_participants other_participant
                ON c.id = other_participant.conversationid
                AND other_participant.phone_number != p.phone_number
            LEFT JOIN
                zp_users from_user
                ON other_participant.phone_number = from_user.phone_number
            LEFT JOIN
                zp_contacts contact
                ON contact.phone_number = p.phone_number
                AND contact.contact_phone_number = other_participant.phone_number
            LEFT JOIN
                LatestMessages last_msg
                ON c.id = last_msg.conversationid AND last_msg.rn = 1
            WHERE
                p.phone_number = ?
            GROUP BY conversation_name
            ORDER BY
                last_msg.created_at DESC
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

lib.callback.register('z-phone:server:GetChatting', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)

    if Player ~= nil and phoneItem and phoneItem.metadata and phoneItem.metadata.phone_number then
        local phone_number = phoneItem.metadata.phone_number
        local query = [[
            SELECT
                * 
            FROM
                (
                SELECT
                    zpcm.id,
                    zpcm.content as message,
                    zpcm.media,
                    DATE_FORMAT(zpcm.created_at, '%d %b %Y %H:%i') as time,
                    zpcm.sender_phone_number as sender_citizenid,
                    zpcm.is_deleted,
                    TIMESTAMPDIFF(MINUTE, zpcm.created_at, NOW()) AS minute_diff
                FROM
                    zp_conversation_messages zpcm 
                WHERE
                    conversationid = ? 
                ORDER BY
                    id DESC 
                    LIMIT 200 
                ) AS subquery 
            ORDER BY
                id ASC;
        ]]

        local result = MySQL.query.await(query, {
            body.conversationid
        })

        if result then
            return result
        else
            return {}
        end
    end
    return {}
end)

lib.callback.register('z-phone:server:SendChatting', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)

    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end
    local phone_number = phoneItem.metadata.phone_number
    local citizenid = Player.citizenid
    local query = "INSERT INTO zp_conversation_messages (conversationid, sender_phone_number, content, media) VALUES (?, ?, ?, ?)"

    local id = MySQL.insert.await(query, {
        body.conversationid,
        phone_number,
        body.message,
        body.media,
    })

    if not id then return false end

    if not body.is_group then
        local contactName = MySQL.scalar.await([[
            SELECT
            COALESCE(
                (SELECT contact_name FROM zp_contacts WHERE citizenid = ? and contact_citizenid = ?),
                (SELECT phone_number FROM zp_users WHERE citizenid = ?)
            ) AS name
        ]], { body.to_citizenid, citizenid, citizenid })
        if contactName then
            body.from = contactName
            body.from_citizenid = citizenid
            local TargetPlayer = xCore.GetPlayerByIdentifier(body.to_citizenid)
            if TargetPlayer ~= nil then
                TriggerClientEvent("z-phone:client:sendNotifMessage", TargetPlayer.source, body)
            end
        end
    else
        local queryGetParticipants = [[
            SELECT * FROM zp_conversation_participants WHERE conversationid = ?
        ]]
        local participans = MySQL.query.await(queryGetParticipants, {body.conversationid})
    
        if not participans then
            return false
        end

        for i, v in pairs(participans) do
            if v.citizenid ~= citizenid then
                local TargetPlayer = xCore.GetPlayerByIdentifier(v.citizenid)
                if TargetPlayer ~= nil then
                    body.to_citizenid = v.citizenid
                    body.from = body.conversation_name
                    body.from_citizenid = citizenid
                    TriggerClientEvent("z-phone:client:sendNotifMessage", TargetPlayer.source, body)
                end
            end
        end
    end

    return id
end)

lib.callback.register('z-phone:server:DeleteMessage', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)

    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end
    local phone_number = phoneItem.metadata.phone_number

    local query = [[
        UPDATE zp_conversation_messages SET is_deleted = 1 WHERE id = ? and sender_phone_number = ?
    ]]

    MySQL.update.await(query, {
        body.id,
        phone_number
    })

    return true
end)

lib.callback.register('z-phone:server:CreateGroup', function(source, body)
    local Player = xCore.GetPlayerBySource(source)

    if Player == nil then return false end
    local citizenid = Player.citizenid

    local queryGetUser = [[
        SELECT * FROM zp_users WHERE phone_number IN (?)
    ]]
    local users = MySQL.query.await(queryGetUser, {body.phone_numbers})

    if not users then
        return false
    end

    local queryNewConv = "INSERT INTO zp_conversations (name, is_group, admin_citizenid) VALUES (?, ?, ?)"
    local conversationid = MySQL.insert.await(queryNewConv, {
        body.name,
        true,
        citizenid,
    })

    local queryParticipant = "INSERT INTO zp_conversation_participants (conversationid, citizenid) VALUES (?, ?)"
    MySQL.insert.await(queryParticipant, {
        conversationid,
        citizenid,
    })

    for i, v in pairs(users) do
        MySQL.Async.insert(queryParticipant, {
            conversationid,
            v.citizenid,
        })

        if v.citizenid ~= citizenid then
            local TargetPlayer = xCore.GetPlayerByIdentifier(v.citizenid)
            if TargetPlayer ~= nil then
                TriggerClientEvent("z-phone:client:sendNotifInternal", TargetPlayer.source, {
                    type = "Notification",
                    from = "Message",
                    message = "You invited to group ".. body.name
                })
            end
        end
    end

    local queryInitChat = "INSERT INTO zp_conversation_messages (conversationid, sender_citizenid, content) VALUES (?, ?, ?)"
    MySQL.insert.await(queryInitChat, {
        conversationid,
        citizenid,
        "Created this group."
    })
    return conversationid
end)