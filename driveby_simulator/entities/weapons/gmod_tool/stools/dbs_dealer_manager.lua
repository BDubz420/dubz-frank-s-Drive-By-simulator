TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Dealer Manager"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["team"] = "1"
TOOL.ClientConVar["dealer"] = "1"
TOOL.ClientConVar["height"] = "12"

if CLIENT then
    language.Add("tool.dbs_dealer_manager.name", "DBS Dealer Manager")
    language.Add("tool.dbs_dealer_manager.desc", "Set dealer spawn points and link/unlink doors")
    language.Add("tool.dbs_dealer_manager.0", "Left click world: set dealer spawn | Right click door: toggle door link | Left click Eli: tag team/dealer")
end

function TOOL:LeftClick(tr)
    if CLIENT then return true end
    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end
    if not tr.Hit then return false end

    local teamID = tonumber(self:GetClientInfo("team")) or ply:Team()
    local dealerID = math.max(1, math.floor(tonumber(self:GetClientInfo("dealer")) or 1))

    if IsValid(tr.Entity) and tr.Entity:GetClass() == "dbs_npc_eli" then
        if tr.Entity.SetDealerID then tr.Entity:SetDealerID(dealerID) end
        if tr.Entity.SetDealerTeam then tr.Entity:SetDealerTeam(teamID) end
        DBS.Util.Notify(ply, ("Tagged Eli as Team %d Dealer #%d"):format(teamID, dealerID))
        return true
    end

    local h = tonumber(self:GetClientInfo("height")) or 12
    local pos = tr.HitPos + Vector(0, 0, h)
    local ang = Angle(0, ply:EyeAngles().y, 0)

    if DBS.Eli and DBS.Eli.SetDealerSpawn then
        DBS.Eli.SetDealerSpawn(teamID, dealerID, pos, ang)
        DBS.Eli.RefreshDoorLinkedDealers()
        DBS.Util.Notify(ply, ("Set spawn for Team %d Dealer #%d"):format(teamID, dealerID))
        return true
    end

    return false
end

function TOOL:RightClick(tr)
    if CLIENT then return true end
    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end

    local teamID = tonumber(self:GetClientInfo("team")) or ply:Team()
    local dealerID = math.max(1, math.floor(tonumber(self:GetClientInfo("dealer")) or 1))

    local door = tr.Entity
    if not IsValid(door) or not DBS.Doors or not DBS.Doors.IsDoor or not DBS.Doors.IsDoor(door) then
        DBS.Util.Notify(ply, "Look at a door and right click to link/unlink.")
        return false
    end

    local id = DBS.Doors.GetDoorID and DBS.Doors.GetDoorID(door)
    if not id or not DBS.Eli or not DBS.Eli.ToggleDealerDoorLink then return false end

    local linked = DBS.Eli.ToggleDealerDoorLink(teamID, dealerID, id)
    DBS.Eli.RefreshDoorLinkedDealers()
    DBS.Util.Notify(ply, linked and "Door linked to dealer." or "Door unlinked from dealer.")
    return true
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Step 1: set Team + Dealer #.\nStep 2: left-click world to set where that dealer should spawn in base.\nStep 3: right-click each base door to link it.\nWhen linked doors are owned by that team, dealer auto-spawns." })
    panel:NumSlider("Team ID", "dbs_dealer_manager_team", 1, 3, 0)
    panel:NumSlider("Dealer #", "dbs_dealer_manager_dealer", 1, 20, 0)
    panel:NumSlider("Height", "dbs_dealer_manager_height", 0, 64, 0)
end
