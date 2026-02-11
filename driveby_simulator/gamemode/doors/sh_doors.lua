DBS = DBS or {}
DBS.Doors = DBS.Doors or {}

function DBS.Doors.IsDoor(ent)
    if not IsValid(ent) then return false end

    local class = ent:GetClass()
    return class == "prop_door_rotating" or class == "func_door" or class == "func_door_rotating"
end

function DBS.Doors.GetOwnerTeam(door)
    if not IsValid(door) then return 0 end
    return door:GetNWInt("DBS_DoorOwner", 0)
end

function DBS.Doors.GetTeamColor(teamID)
    if teamID == DBS.Const.Teams.RED then return team.GetColor(DBS.Const.Teams.RED) end
    if teamID == DBS.Const.Teams.BLUE then return team.GetColor(DBS.Const.Teams.BLUE) end
    if teamID == DBS.Const.Teams.POLICE then return team.GetColor(DBS.Const.Teams.POLICE) end
    return Color(180, 180, 180)
end

function DBS.Doors.GetOwnerLabel(ownerTeam)
    if ownerTeam == DBS.Const.Teams.RED then return "Owned by Red Gang" end
    if ownerTeam == DBS.Const.Teams.BLUE then return "Owned by Blue Gang" end
    if ownerTeam == DBS.Const.Teams.POLICE then return "Owned by Police" end
    return "Unowned"
end
