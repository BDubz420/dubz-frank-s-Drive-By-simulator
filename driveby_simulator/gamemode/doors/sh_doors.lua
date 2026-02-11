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
    return Color(185, 185, 185)
end

function DBS.Doors.GetOwnerLabel(ownerTeam)
    if ownerTeam == DBS.Const.Teams.RED then return "Bloodz Controlled" end
    if ownerTeam == DBS.Const.Teams.BLUE then return "Cripz Controlled" end
    if ownerTeam == DBS.Const.Teams.POLICE then return "Police Controlled" end
    return "Unowned"
end

function DBS.Doors.GetDoorID(door)
    if not IsValid(door) then return nil end

    local mapID = door:MapCreationID()
    if mapID and mapID >= 0 then
        return "m" .. mapID
    end

    local pos = door:GetPos()
    local class = door:GetClass() or "door"

    return string.format("p_%s_%d_%d_%d", class, math.Round(pos.x), math.Round(pos.y), math.Round(pos.z))
end
