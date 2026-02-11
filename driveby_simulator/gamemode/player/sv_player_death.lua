DBS = DBS or {}
DBS.Player = DBS.Player or {}

util.AddNetworkString("DBS_DeathInfo")

local RESPAWN_DELAY = 10

hook.Add("PlayerDeath", "DBS.PlayerDeathCore", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end

    if DBS.Player and DBS.Player.DropAllVulnerable then DBS.Player.DropAllVulnerable(victim) end
    DBS.Player.SetCred(victim, 0)
    victim:SetNWInt("DBS_Kills", 0)

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

    local respawnAt = CurTime() + RESPAWN_DELAY
    victim:SetNWFloat("DBS_RespawnAt", respawnAt)

    net.Start("DBS_DeathInfo")
        net.WriteString(mode)
        net.WriteString(killerName)
        net.WriteFloat(respawnAt)
    net.Send(victim)

    timer.Create("DBS.Respawn." .. victim:SteamID64(), RESPAWN_DELAY, 1, function()
        if IsValid(victim) and not victim:Alive() then
            victim:Spawn()
        end
    end)
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


hook.Add("PlayerDeathThink", "DBS.RespawnDelay", function(ply)
    local at = ply:GetNWFloat("DBS_RespawnAt", 0)
    if at > CurTime() then
        return false
    end
end)

hook.Add("PlayerSpawn", "DBS.ClearRespawnDelay", function(ply)
    ply:SetNWFloat("DBS_RespawnAt", 0)
    timer.Remove("DBS.Respawn." .. ply:SteamID64())
end)

hook.Add("PlayerDisconnected", "DBS.ClearRespawnTimer", function(ply)
    timer.Remove("DBS.Respawn." .. ply:SteamID64())
end)
