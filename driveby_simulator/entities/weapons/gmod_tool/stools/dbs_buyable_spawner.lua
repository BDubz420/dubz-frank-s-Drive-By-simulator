TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Buyable Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["mode"] = "utility"
TOOL.ClientConVar["class"] = "dbs_money_printer"
TOOL.ClientConVar["price"] = "3000"
TOOL.ClientConVar["team"] = "1"
TOOL.ClientConVar["dealer"] = "1"
TOOL.ClientConVar["count"] = "1"
TOOL.ClientConVar["height"] = "12"

if CLIENT then
    language.Add("tool.dbs_buyable_spawner.name", "DBS Dealer Manager")
    language.Add("tool.dbs_buyable_spawner.desc", "Configure dealer IDs, utility spots, dealer spawns, and door links")
    language.Add("tool.dbs_buyable_spawner.0", "Modes: Utility Spot / Dealer Spawn / Link Door")
end

local VALID = {
    ["dbs_money_printer"] = true,
    ["dbs_coke_printer"] = true,
    ["dbs_coke_drying_table"] = true,
    ["dbs_coke_brick_packer"] = true
}

local function ReadTeam(self, ply)
    return tonumber(self:GetClientInfo("team")) or (IsValid(ply) and ply:Team()) or 0
end

function TOOL:LeftClick(tr)
    if CLIENT then return true end
    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end
    if not tr.Hit then return false end

    local mode = self:GetClientInfo("mode")
    local teamID = ReadTeam(self, ply)
    local dealerID = math.max(1, math.floor(tonumber(self:GetClientInfo("dealer")) or 1))

    if IsValid(tr.Entity) and tr.Entity:GetClass() == "dbs_npc_eli" then
        if tr.Entity.SetDealerID then tr.Entity:SetDealerID(dealerID) end
        if tr.Entity.SetDealerTeam then tr.Entity:SetDealerTeam(teamID) end
        DBS.Util.Notify(ply, ("Tagged Eli as team %d dealer #%d."):format(teamID, dealerID))
        return true
    end

    local height = tonumber(self:GetClientInfo("height")) or 12
    local pos = tr.HitPos + Vector(0, 0, height)
    local ang = Angle(0, ply:EyeAngles().y, 0)

    if mode == "dealer_spawn" then
        if not DBS.Eli or not DBS.Eli.SetDealerSpawn then return false end
        DBS.Eli.SetDealerSpawn(teamID, dealerID, pos, ang)
        DBS.Util.Notify(ply, ("Set dealer spawn for team %d dealer #%d."):format(teamID, dealerID))
        return true
    end

    if mode == "link_door" then
        local door = tr.Entity
        if not IsValid(door) or not DBS.Doors or not DBS.Doors.IsDoor or not DBS.Doors.IsDoor(door) then
            DBS.Util.Notify(ply, "Look at a door to link.")
            return false
        end
        local id = DBS.Doors.GetDoorID and DBS.Doors.GetDoorID(door)
        if not id then return false end
        local linked = DBS.Eli.ToggleDealerDoorLink(teamID, dealerID, id)
        DBS.Util.Notify(ply, linked and "Linked door to dealer." or "Unlinked door from dealer.")
        DBS.Eli.RefreshDoorLinkedDealers()
        return true
    end

    local class = self:GetClientInfo("class")
    if not VALID[class] then DBS.Util.Notify(ply, "Invalid class.") return false end
    if not DBS.Eli or not DBS.Eli.SetBuyableSpot then return false end

    local price = math.max(1, tonumber(self:GetClientInfo("price")) or 1000)
    local count = math.max(1, tonumber(self:GetClientInfo("count")) or 1)

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

    DBS.Util.Notify(ply, ("Set utility spot: team %d dealer #%d %s."):format(teamID, dealerID, class))
    return true
end

if CLIENT then
    local TOOL_MENU

    function TOOL:RightClick()
        if IsValid(TOOL_MENU) then TOOL_MENU:MakePopup() TOOL_MENU:Center() return true end

        local fr = vgui.Create("DFrame")
        fr:SetSize(380, 360)
        fr:Center()
        fr:SetTitle("DBS Dealer Manager")
        fr:MakePopup()
        fr.OnRemove = function() TOOL_MENU = nil end
        TOOL_MENU = fr

        local mode = vgui.Create("DComboBox", fr)
        mode:Dock(TOP) mode:DockMargin(8, 8, 8, 4)
        mode:SetValue(GetConVarString("dbs_buyable_spawner_mode"))
        mode:AddChoice("utility")
        mode:AddChoice("dealer_spawn")
        mode:AddChoice("link_door")
        mode.OnSelect = function(_, _, v) RunConsoleCommand("dbs_buyable_spawner_mode", v) end

        local classBox = vgui.Create("DComboBox", fr)
        classBox:Dock(TOP) classBox:DockMargin(8, 2, 8, 4)
        classBox:SetValue(GetConVarString("dbs_buyable_spawner_class"))
        classBox:AddChoice("dbs_money_printer")
        classBox:AddChoice("dbs_coke_printer")
        classBox:AddChoice("dbs_coke_drying_table")
        classBox:AddChoice("dbs_coke_brick_packer")
        classBox.OnSelect = function(_, _, v) RunConsoleCommand("dbs_buyable_spawner_class", v) end

        local function addNum(label, cvar)
            local row = vgui.Create("DPanel", fr)
            row:Dock(TOP) row:DockMargin(8, 2, 8, 2) row:SetTall(24) row.Paint = nil
            local l = vgui.Create("DLabel", row) l:Dock(LEFT) l:SetWide(150) l:SetText(label)
            local e = vgui.Create("DTextEntry", row) e:Dock(FILL) e:SetText(GetConVarString(cvar))
            e.OnEnter = function(self) RunConsoleCommand(cvar, self:GetValue()) end
        end

        addNum("Team ID", "dbs_buyable_spawner_team")
        addNum("Dealer #", "dbs_buyable_spawner_dealer")
        addNum("Price", "dbs_buyable_spawner_price")
        addNum("Max Count", "dbs_buyable_spawner_count")
        addNum("Height Offset", "dbs_buyable_spawner_height")
        return true
    end
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Modes: utility spot, dealer spawn, door link. Left click an Eli NPC to set its team/dealer ID." })
end
