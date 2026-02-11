DBS = DBS or {}
DBS.Court = DBS.Court or {}

function DBS.Court.SendPlayer(ply)
    if not IsValid(ply) then return end

    local minutes = DBS.Court.CalculateSentence(ply)

    ply.DBS_JailTime = minutes * 60

    -- Reset police kill count AFTER sentencing
    ply:SetNWInt("DBS_PoliceKills", 0)

    -- Spawn at courthouse
    if DBS.Config.Spawns and DBS.Config.Spawns.Court then
        ply:SetPos(DBS.Config.Spawns.Court.Pos)
        ply:SetEyeAngles(DBS.Config.Spawns.Court.Ang or Angle(0,0,0))
    end

    -- TEMP feedback
    ply:ChatPrint("Mayor: You killed people.")
    ply:ChatPrint("Sentence: " .. minutes .. " minute(s).")
    ply:ChatPrint("Type: dbs_jail_ok  or  dbs_jail_escape")
end
