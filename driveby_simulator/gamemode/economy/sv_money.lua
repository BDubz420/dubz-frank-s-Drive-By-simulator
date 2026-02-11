DBS = DBS or {}
DBS.Economy = DBS.Economy or {}

local function GetScaledPayout(ply, baseAmount)
    local cfg = DBS.Config.Economy
    if not cfg then return baseAmount end

    local softCap = cfg.SoftWalletCap or 0
    local scale = cfg.SoftCapPayoutScale or 1

    if softCap <= 0 then
        return baseAmount
    end

    if ply:GetMoney() >= softCap then
        return math.max(1, math.floor(baseAmount * scale))
    end

    return baseAmount
end

local function RewardKill(attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end

    local cfg = DBS.Config.Economy
    if not cfg then return end

    local amount = DBS.Util.IsPolice(attacker) and (cfg.PoliceKillReward or 0) or (cfg.GangKillReward or 0)
    if amount <= 0 then return end

    amount = GetScaledPayout(attacker, amount)
    attacker:AddMoney(amount)
    DBS.Util.Notify(attacker, "Kill reward: $" .. string.Comma(amount))
end

hook.Add("PlayerDeath", "DBS.Economy.KillReward", function(victim, inflictor, attacker)
    if attacker == victim then return end
    RewardKill(attacker)
end)

function DBS.Economy.PayStipend(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if ply:Team() == TEAM_UNASSIGNED or ply:Team() == 0 then return end

    local cfg = DBS.Config.Economy
    if not cfg then return end

    local amount = DBS.Util.IsPolice(ply) and (cfg.PoliceStipend or 0) or (cfg.GangStipend or 0)
    if amount <= 0 then return end

    amount = GetScaledPayout(ply, amount)
    ply:AddMoney(amount)
    DBS.Util.Notify(ply, "Street income: $" .. string.Comma(amount))
end

local function StartStipendTimer(ply)
    if not IsValid(ply) then return end

    local cfg = DBS.Config.Economy
    local interval = cfg and cfg.StipendInterval or 90

    timer.Create("DBS.Stipend." .. ply:SteamID64(), interval, 0, function()
        if not IsValid(ply) then return end
        DBS.Economy.PayStipend(ply)
    end)
end

hook.Add("PlayerInitialSpawn", "DBS.Economy.StartStipend", function(ply)
    timer.Simple(2, function()
        StartStipendTimer(ply)
    end)
end)

hook.Add("PlayerDisconnected", "DBS.Economy.StopStipend", function(ply)
    timer.Remove("DBS.Stipend." .. ply:SteamID64())
end)


local function DropMoneyAtPlayer(ply, amount)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then return false end

    local ent = ents.Create("dbs_money_drop")
    if not IsValid(ent) then return false end

    ent:SetPos(ply:GetPos() + Vector(0, 0, 20))
    ent:SetAmount(amount)
    ent:Spawn()
    return true
end

concommand.Add("dbs_dropmoney", function(ply, _, args)
    if not IsValid(ply) then return end
    local amt = math.floor(tonumber(args[1]) or 0)
    if amt <= 0 then
        DBS.Util.Notify(ply, "Usage: dbs_dropmoney <amount>")
        return
    end

    amt = math.min(amt, ply:GetMoney())
    if amt <= 0 then return end

    if DropMoneyAtPlayer(ply, amt) then
        ply:AddMoney(-amt)
        DBS.Util.Notify(ply, "Dropped $" .. string.Comma(amt) .. ".")
    end
end)

hook.Add("PlayerSay", "DBS.DropMoneyChat", function(ply, txt)
    local msg = string.Trim(string.lower(txt or ""))
    if not string.StartWith(msg, "!dropmoney") and not string.StartWith(msg, "/dropmoney") then return end
    local amount = tonumber(string.match(msg, "%s+(%d+)")) or 0
    if amount <= 0 then
        DBS.Util.Notify(ply, "Usage: !dropmoney <amount>")
        return ""
    end

    amount = math.min(math.floor(amount), ply:GetMoney())
    if amount > 0 and DropMoneyAtPlayer(ply, amount) then
        ply:AddMoney(-amount)
        DBS.Util.Notify(ply, "Dropped $" .. string.Comma(amount) .. ".")
    end
    return ""
end)
