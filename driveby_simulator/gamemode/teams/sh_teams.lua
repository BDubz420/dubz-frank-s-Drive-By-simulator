-- gamemode/teams/sh_teams.lua
DBS = DBS or {}
DBS.Teams = DBS.Teams or {}

team.SetUp(DBS.Const.Teams.RED, "Red Gang", Color(200, 50, 50), true)
team.SetUp(DBS.Const.Teams.BLUE, "Blue Gang", Color(50, 80, 200), true)
team.SetUp(DBS.Const.Teams.POLICE, "Police", Color(50, 120, 255), true)
team.SetUp(TEAM_UNASSIGNED, "Unassigned", Color(200, 200, 200), false)
