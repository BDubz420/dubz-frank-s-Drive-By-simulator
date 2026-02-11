DBS = DBS or {}
DBS.Jerome = DBS.Jerome or {}

util.AddNetworkString("DBS_Jerome_Open")
util.AddNetworkString("DBS_Jerome_SelectTeam")

function DBS.Jerome.OpenMenu(ply)
    if not IsValid(ply) then return end

    -- Must be unassigned
    if ply:Team() ~= TEAM_UNASSIGNED and ply:Team() ~= 0 then
        ply:ChatPrint("You already chose a side.")
        return
    end

    net.Start("DBS_Jerome_Open")
    net.Send(ply)
end

net.Receive("DBS_Jerome_SelectTeam", function(_, ply)
    if not IsValid(ply) then return end

    -- Must still be unassigned
    if ply:Team() ~= TEAM_UNASSIGNED and ply:Team() ~= 0 then return end

    local teamID = net.ReadUInt(4)

    -- Validate team
    if teamID ~= DBS.Const.Teams.RED
    and teamID ~= DBS.Const.Teams.BLUE
    and teamID ~= DBS.Const.Teams.POLICE then
        return
    end

    ply:SetTeam(teamID)
    ply:Spawn()
end)

