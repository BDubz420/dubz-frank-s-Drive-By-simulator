TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Utility Spot Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["class"] = "dbs_money_printer"
TOOL.ClientConVar["price"] = "3000"
TOOL.ClientConVar["team"] = "1"
TOOL.ClientConVar["dealer"] = "1"
TOOL.ClientConVar["count"] = "1"
TOOL.ClientConVar["height"] = "12"

if CLIENT then
    language.Add("tool.dbs_buyable_spawner.name", "DBS Utility Spot Tool")
    language.Add("tool.dbs_buyable_spawner.desc", "Set utility spawn spots for a specific team + dealer number")
    language.Add("tool.dbs_buyable_spawner.0", "Left click world: set utility spawn spot | Left click Eli: tag team/dealer")
end

local VALID = {
    ["dbs_money_printer"] = true,
    ["dbs_coke_printer"] = true,
    ["dbs_coke_drying_table"] = true,
    ["dbs_coke_brick_packer"] = true
}

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

    local class = self:GetClientInfo("class")
    if not VALID[class] then DBS.Util.Notify(ply, "Invalid utility class.") return false end
    if not DBS.Eli or not DBS.Eli.SetBuyableSpot then return false end

    local price = math.max(1, tonumber(self:GetClientInfo("price")) or 1000)
    local count = math.max(1, tonumber(self:GetClientInfo("count")) or 1)
    local height = tonumber(self:GetClientInfo("height")) or 12

    local pos = tr.HitPos + Vector(0, 0, height)
    local ang = Angle(0, ply:EyeAngles().y, 0)
    DBS.Eli.SetBuyableSpot(teamID, class, pos, ang, dealerID)

    if class == "dbs_money_printer" then
        DBS.Config.Printer.Price, DBS.Config.Printer.MaxPerPlayer = price, count
    elseif class == "dbs_coke_printer" then
        DBS.Config.CokePrinter.Price, DBS.Config.CokePrinter.MaxPerPlayer = price, count
    elseif class == "dbs_coke_drying_table" then
        DBS.Config.CokeDryingTable = DBS.Config.CokeDryingTable or {}
        DBS.Config.CokeDryingTable.Price, DBS.Config.CokeDryingTable.MaxPerPlayer = price, count
    elseif class == "dbs_coke_brick_packer" then
        DBS.Config.CokeBrickPacker = DBS.Config.CokeBrickPacker or {}
        DBS.Config.CokeBrickPacker.Price, DBS.Config.CokeBrickPacker.MaxPerPlayer = price, count
    end

    DBS.Util.Notify(ply, ("Set %s spot for Team %d Dealer #%d"):format(class, teamID, dealerID))
    return true
end

if CLIENT then
    function TOOL:Think()
        local tr = LocalPlayer():GetEyeTrace()
        if not tr.Hit then return end
        local mdlByClass = {
            dbs_money_printer = "models/props_c17/consolebox01a.mdl",
            dbs_coke_printer = "models/props_c17/TrapPropeller_Engine.mdl",
            dbs_coke_drying_table = "models/props_c17/FurnitureTable002a.mdl",
            dbs_coke_brick_packer = "models/hunter/blocks/cube025x05x025.mdl"
        }
        local mdl = mdlByClass[self:GetClientInfo("class")] or "models/props_c17/consolebox01a.mdl"
        if not IsValid(self.GhostEntity) then self:MakeGhostEntity(mdl, Vector(), Angle()) end
        if IsValid(self.GhostEntity) then
            local h = tonumber(self:GetClientInfo("height")) or 12
            self.GhostEntity:SetModel(mdl)
            self.GhostEntity:SetPos(tr.HitPos + Vector(0, 0, h))
            self.GhostEntity:SetAngles(Angle(0, LocalPlayer():EyeAngles().y, 0))
        end
    end
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Step 1: choose Team + Dealer #. Step 2: left-click an Eli to tag it. Step 3: choose utility class and left-click world to set its spawn spot for that dealer." })
    panel:TextEntry("Utility Class", "dbs_buyable_spawner_class")
    panel:NumSlider("Team ID", "dbs_buyable_spawner_team", 1, 3, 0)
    panel:NumSlider("Dealer #", "dbs_buyable_spawner_dealer", 1, 20, 0)
    panel:NumSlider("Price", "dbs_buyable_spawner_price", 1, 50000, 0)
    panel:NumSlider("Max Count", "dbs_buyable_spawner_count", 1, 20, 0)
    panel:NumSlider("Height", "dbs_buyable_spawner_height", 0, 64, 0)
end
