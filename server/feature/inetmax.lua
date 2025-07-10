lib.callback.register('z-phone:server:GetInternetData', function(source)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return {} end

    local phone_number = phoneItem.metadata.phone_number
    local queryTopupQuery = [[
        SELECT
        total,
        flag,
        label,
        DATE_FORMAT(created_at, '%d %b %Y') as created_at
        FROM zp_inetmax_histories WHERE phone_number = ? AND flag = ? ORDER BY id desc limit 50
    ]]

    local topups = MySQL.query.await(queryTopupQuery, {
        phone_number,
        "CREDIT"
    })

    local usages = MySQL.query.await(queryTopupQuery, {
        phone_number,
        "USAGE"
    })

    local queryUsageGroup = "SELECT label as app, total FROM zp_inetmax_histories WHERE flag = 'USAGE' and phone_number = ? GROUP BY label"
    local usageGroup = MySQL.query.await(queryUsageGroup, {
        phone_number,
    })

    return {
        topup_histories = topups,
        usage_histories = usages,
        group_usage = usageGroup
    }
end)

lib.callback.register('z-phone:server:TopupInternetData', function(source, body)
    local Player = xCore.GetPlayerBySource(source)
    local phoneItem = xCore.GetPhoneItem(source)
    if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return 0 end

    local phone_number = phoneItem.metadata.phone_number
    if Player.money.bank < body.total then 
        TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
            type = "Notification",
            from = "InetMax",
            message = "Bank Balance is not enough"
        })
        return false
    end

    local IncrementBalance = math.floor(body.total / Config.App.InetMax.TopupRate.Price) * Config.App.InetMax.TopupRate.InKB
    local queryHistories = "INSERT INTO zp_inetmax_histories (phone_number, flag, label, total) VALUES (?, ?, ?, ?)"
    local id = MySQL.insert.await(queryHistories, {
        phone_number,
        "CREDIT",
        body.label,
        IncrementBalance
    })

    local queryIncrementBalance = [[
        UPDATE zp_users SET inetmax_balance = inetmax_balance + ? WHERE phone_number = ?
    ]]

    MySQL.update.await(queryIncrementBalance, {
        IncrementBalance,
        phone_number
    })

    Player.removeAccountMoney('bank', body.total, "InetMax purchase")
    xCore.AddMoneyBankSociety(Config.App.InetMax.SocietySeller, body.total, "InetMax purchase")

    TriggerClientEvent("z-phone:client:sendNotifInternal", source, {
        type = "Notification",
        from = "InetMax",
        message = "Purchase Successful"
    })

    local content = [[
Thank you for choosing our services! We are pleased to confirm that your purchase of the internet data package has been successful.
\
Total: %s \
Rate : $%s / %sKB \
Status : %s \
\
Your data package will be activated shortly, and you’ll receive an email with all the necessary details. If you have any questions or need further assistance, please don't hesitate to reach out.
\
Thank you for being a valued customer!
    ]]
    MySQL.Async.insert('INSERT INTO zp_emails (institution, phone_number, subject, content) VALUES (?, ?, ?, ?)', {
        "inetmax",
        phone_number,
        "Your Internet Data Package Purchase Confirmation",
        string.format(content, body.total, Config.App.InetMax.TopupRate.Price, Config.App.InetMax.TopupRate.InKB, "Success"),
    })
    
    return IncrementBalance
end)

local function UseInternetData(phone_number, app, totalInKB)
    local queryHistories = "INSERT INTO zp_inetmax_histories (phone_number, flag, label, total) VALUES (?, ?, ?, ?)"
    MySQL.Async.insert(queryHistories, {
        phone_number,
        "USAGE",
        app,
        totalInKB
    })

    local queryUpdateBalance = [[
        UPDATE zp_users SET inetmax_balance = inetmax_balance - ? WHERE phone_number = ?
    ]]
    MySQL.Async.execute(queryUpdateBalance, {
        totalInKB,
        phone_number
    })
end

RegisterNetEvent('z-phone:server:usage-internet-data', function(app, usageInKB)
    local src = source
    if Config.App.InetMax.IsUseInetMax then
        local Player = xCore.GetPlayerBySource(src)
        local phoneItem = xCore.GetPhoneItem(src)
        if Player == nil or not phoneItem or not phoneItem.metadata or not phoneItem.metadata.phone_number then return false end

        local phone_number = phoneItem.metadata.phone_number
        UseInternetData(phone_number, app, usageInKB)

        TriggerClientEvent("z-phone:client:usage-internet-data", src,  app, usageInKB)
    end
end)