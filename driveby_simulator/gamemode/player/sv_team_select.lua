DBS = DBS or {}

local function SetTeamCmd(ply, teamID)
    if not IsValid(ply) then return end

    -- Must be unassigned to choose
    if ply:Team() ~= TEAM_UNASSIGNED and ply:Team() ~= 0 then
        ply:ChatPrint("You already chose a side.")
        return
    end

    ply:SetTeam(teamID)
    ply:Spawn()
end


concommand.Add("dbs_join_red", function(ply)
    SetTeamCmd(ply, DBS.Const.Teams.RED)
end)

concommand.Add("dbs_join_blue", function(ply)
    SetTeamCmd(ply, DBS.Const.Teams.BLUE)
end)

concommand.Add("dbs_join_police", function(ply)
    SetTeamCmd(ply, DBS.Const.Teams.POLICE)
end)
