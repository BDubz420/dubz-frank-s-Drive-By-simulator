DBS = DBS or {}

local TeamAlias = {
    red = DBS.Const.Teams.RED,
    blue = DBS.Const.Teams.BLUE,
    police = DBS.Const.Teams.POLICE,
    cop = DBS.Const.Teams.POLICE
}

local function SetTeamCmd(ply, teamID)
    if not IsValid(ply) then return end
    if not teamID then return end

    ply:SetTeam(teamID)
    ply:Spawn()

    DBS.Util.Notify(ply, "Joined " .. (team.GetName(teamID) or "team") .. ".")
end

concommand.Add("dbs_join_red", function(ply) SetTeamCmd(ply, DBS.Const.Teams.RED) end)
concommand.Add("dbs_join_blue", function(ply) SetTeamCmd(ply, DBS.Const.Teams.BLUE) end)
concommand.Add("dbs_join_police", function(ply) SetTeamCmd(ply, DBS.Const.Teams.POLICE) end)

concommand.Add("dbs_join_team", function(ply, _, args)
    local key = string.lower(args[1] or "")
    SetTeamCmd(ply, TeamAlias[key])
end)

hook.Add("PlayerSay", "DBS.TeamSwitchChat", function(ply, text)
    local msg = string.lower(string.Trim(text or ""))

    if msg == "!red" or msg == "/red" then
        SetTeamCmd(ply, DBS.Const.Teams.RED)
        return ""
    elseif msg == "!blue" or msg == "/blue" then
        SetTeamCmd(ply, DBS.Const.Teams.BLUE)
        return ""
    elseif msg == "!police" or msg == "/police" or msg == "!cop" then
        SetTeamCmd(ply, DBS.Const.Teams.POLICE)
        return ""
    end
end)
