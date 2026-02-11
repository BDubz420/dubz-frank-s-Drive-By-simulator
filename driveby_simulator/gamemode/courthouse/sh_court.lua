DBS = DBS or {}
DBS.Court = DBS.Court or {}

function DBS.Court.CalculateSentence(ply)
    local kills = ply:GetNWInt("DBS_PoliceKills", 0)
    local minutes = math.floor(kills / 2)
    return math.Clamp(minutes, 1, 5)
end
