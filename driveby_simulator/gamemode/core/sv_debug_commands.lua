if not SERVER then return end

local function FindPlayerByString(str)
    if not str then return nil end
    str = string.lower(str)

    for _, ply in ipairs(player.GetAll()) do
        if string.find(string.lower(ply:Nick()), str, 1, true) then
            return ply
        end
        if string.lower(ply:SteamID()) == str then
            return ply
        end
    end

    return nil
end

-- Give money
concommand.Add("dbs_givemoney", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    local target = FindPlayerByString(args[1])
    local amount = tonumber(args[2])

    if not IsValid(target) or not amount then
        if IsValid(ply) then
            ply:ChatPrint("Usage: dbs_givemoney <player> <amount>")
        end
        return
    end

    DBS.Player.AddMoney(target, amount)

    if IsValid(ply) then
        ply:ChatPrint("[DBS] Gave $" .. amount .. " to " .. target:Nick())
    end

    target:ChatPrint("[DBS] You received $" .. amount)
end)

concommand.Add("dbs_takemoney", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    local target = FindPlayerByString(args[1])
    local amount = tonumber(args[2])

    if not IsValid(target) or not amount then
        if IsValid(ply) then
            ply:ChatPrint("Usage: dbs_takemoney <player> <amount>")
        end
        return
    end

    DBS.Player.AddMoney(target, -amount)

    if IsValid(ply) then
        ply:ChatPrint("[DBS] Took $" .. amount .. " from " .. target:Nick())
    end

    target:ChatPrint("[DBS] $" .. amount .. " was removed from you")
end)

-- Give cred
concommand.Add("dbs_givecred", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    local target = FindPlayerByString(args[1])
    local amount = tonumber(args[2])

    if not IsValid(target) or not amount then
        if IsValid(ply) then
            ply:ChatPrint("Usage: dbs_givecred <player> <amount>")
        end
        return
    end

    DBS.Player.AddCred(target, amount)

    if IsValid(ply) then
        ply:ChatPrint("[DBS] Gave " .. amount .. " CRED to " .. target:Nick())
    end

    target:ChatPrint("[DBS] You received " .. amount .. " CRED")
end)

concommand.Add("dbs_takecred", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    local target = FindPlayerByString(args[1])
    local amount = tonumber(args[2])

    if not IsValid(target) or not amount then
        if IsValid(ply) then
            ply:ChatPrint("Usage: dbs_takecred <player> <amount>")
        end
        return
    end

    DBS.Player.AddCred(target, -amount)

    if IsValid(ply) then
        ply:ChatPrint("[DBS] Took " .. amount .. " CRED from " .. target:Nick())
    end

    target:ChatPrint("[DBS] " .. amount .. " CRED was removed from you")
end)