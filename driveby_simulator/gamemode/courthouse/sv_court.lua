DBS = DBS or {}
DBS.Court = DBS.Court or {}

util.AddNetworkString("DBS_Court_WaitSentence")

local function GetJudgeSpot()
    local cfg = DBS.Config and DBS.Config.NPC and DBS.Config.NPC.Spawns and DBS.Config.NPC.Spawns.Judge
    if cfg and cfg.Pos then return cfg.Pos, cfg.Ang or Angle(0, 0, 0) end

    if DBS.Config.Spawns and DBS.Config.Spawns.Court then
        return DBS.Config.Spawns.Court.Pos, DBS.Config.Spawns.Court.Ang or Angle(0, 0, 0)
    end

    return nil, nil
end

function DBS.Court.CalculateSentence(ply)
    local kills = ply:GetNWInt("DBS_PoliceKills", 0)
    local mins = math.floor(kills / math.max(1, DBS.Config.Court.KillsPerMinute or 2))
    return math.Clamp(mins, 1, DBS.Config.Court.MaxMinutes or 5)
end

function DBS.Court.SendPlayer(ply)
    if not IsValid(ply) then return end

    local minutes = DBS.Court.CalculateSentence(ply)
    local delay = (DBS.Config.Police and DBS.Config.Police.JudgeSentenceDelay) or 8

    local pos, ang = GetJudgeSpot()
    if pos then
        ply:SetPos(pos)
        ply:SetEyeAngles(ang or Angle(0, 0, 0))
    end

    ply:Freeze(true)

    net.Start("DBS_Court_WaitSentence")
        net.WriteUInt(minutes, 8)
        net.WriteUInt(math.floor(delay), 8)
    net.Send(ply)

    timer.Create("DBS.CourtSentence." .. ply:SteamID64(), delay, 1, function()
        if not IsValid(ply) then return end

        ply:Freeze(false)
        ply:SetNWInt("DBS_PoliceKills", 0)

        DBS.Jail.SendToJail(ply, minutes)
        DBS.Util.Notify(ply, "Judge sentence: " .. minutes .. " minute(s) in jail.")
    end)
end
