DBS = DBS or {}
DBS.Player = DBS.Player or {}

util.AddNetworkString("DBS_DeathInfo")

hook.Add("PlayerDeath", "DBS.PlayerDeathCore", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end

    DBS.Player.DropAllVulnerable(victim)
    DBS.Player.SetCred(victim, 0)

    local killerName = "Unknown"
    local mode = "killed"

    if attacker == victim then
        mode = "suicide"
        killerName = victim:Nick()
    elseif IsValid(attacker) and attacker:IsPlayer() then
        killerName = attacker:Nick()
    elseif IsValid(attacker) then
        killerName = attacker:GetClass()
    end

    net.Start("DBS_DeathInfo")
        net.WriteString(mode)
        net.WriteString(killerName)
    net.Send(victim)
end)

hook.Add("PlayerDeath", "DBS.CredOnKill", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker == victim then return end
    if DBS.Util.IsPolice(attacker) then return end

    local kills = attacker:GetNWInt("DBS_Kills", 0) + 1
    attacker:SetNWInt("DBS_Kills", kills)

    if kills % 5 == 0 then
        DBS.Player.AddCred(attacker, 1)
        attacker:ChatPrint("[DBS] Cred increased to " .. DBS.Player.GetCred(attacker))
    end
end)

hook.Add("PlayerDeath", "DBS.PoliceKillTrack", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker == victim then return end
    if not DBS.Util.IsPolice(attacker) then return end

    local pk = attacker:GetNWInt("DBS_PoliceKills", 0) + 1
    attacker:SetNWInt("DBS_PoliceKills", pk)
end)
