TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Buyable Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["class"] = "dbs_money_printer"
TOOL.ClientConVar["price"] = "3000"
TOOL.ClientConVar["team"] = tostring(DBS and DBS.Const and DBS.Const.Teams and DBS.Const.Teams.RED or 1)
TOOL.ClientConVar["dealer"] = "1"
TOOL.ClientConVar["count"] = "1"
TOOL.ClientConVar["height"] = "12"

if CLIENT then
    language.Add("tool.dbs_buyable_spawner.name", "DBS Buyable Spawner")
    language.Add("tool.dbs_buyable_spawner.desc", "Configure utility spawn spots per dealer number")
    language.Add("tool.dbs_buyable_spawner.0", "Left click world: set spot | Left click Eli: set dealer # | Right click: open config menu")
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

    local dealer = math.max(1, tonumber(self:GetClientInfo("dealer")) or 1)

    if IsValid(tr.Entity) and tr.Entity:GetClass() == "dbs_npc_eli" and tr.Entity.SetDealerID then
        tr.Entity:SetDealerID(dealer)
        if tr.Entity.SetDealerTeam then
            tr.Entity:SetDealerTeam(teamID)
        end
        DBS.Util.Notify(ply, "Set Eli dealer ID #" .. dealer .. " and team " .. teamID .. ".")
        return true
    end

    local class = self:GetClientInfo("class")
    if not VALID[class] then
        DBS.Util.Notify(ply, "Invalid class for buyable spawner.")
        return false
    end

    if not DBS.Eli or not DBS.Eli.SetBuyableSpot then
        DBS.Util.Notify(ply, "Dealer system unavailable.")
        return false
    end

    local price = math.max(1, tonumber(self:GetClientInfo("price")) or 1000)
    local count = math.max(1, tonumber(self:GetClientInfo("count")) or 1)
    local height = tonumber(self:GetClientInfo("height")) or 12

    local ang = Angle(0, ply:EyeAngles().y, 0)
    local pos = tr.HitPos + Vector(0, 0, height)

    DBS.Eli.SetBuyableSpot(teamID, class, pos, ang, dealer)

    if class == "dbs_money_printer" then
        DBS.Config.Printer.Price = price
        DBS.Config.Printer.MaxPerPlayer = count
    elseif class == "dbs_coke_printer" then
        DBS.Config.CokePrinter.Price = price
        DBS.Config.CokePrinter.MaxPerPlayer = count
    elseif class == "dbs_coke_drying_table" then
        DBS.Config.CokeDryingTable = DBS.Config.CokeDryingTable or {}
        DBS.Config.CokeDryingTable.Price = price
        DBS.Config.CokeDryingTable.MaxPerPlayer = count
    elseif class == "dbs_coke_brick_packer" then
        DBS.Config.CokeBrickPacker = DBS.Config.CokeBrickPacker or {}
        DBS.Config.CokeBrickPacker.Price = price
        DBS.Config.CokeBrickPacker.MaxPerPlayer = count
    end

    DBS.Util.Notify(ply, ("Set team %d dealer #%d spot for %s ($%d, max %d)." ):format(teamID, dealer, class, price, count))
    return true
end

if CLIENT then
    local TOOL_MENU

    function TOOL:RightClick()
        if IsValid(TOOL_MENU) then
            TOOL_MENU:MakePopup()
            TOOL_MENU:Center()
            return true
        end

        local fr = vgui.Create("DFrame")
        fr:SetSize(360, 300)
        fr:Center()
        fr:SetTitle("DBS Buyable Spawner Config")
        fr:MakePopup()
        fr.OnRemove = function()
            TOOL_MENU = nil
        end
        TOOL_MENU = fr

        local classBox = vgui.Create("DComboBox", fr)
        classBox:Dock(TOP)
        classBox:DockMargin(8, 8, 8, 4)
        classBox:SetValue(GetConVarString("dbs_buyable_spawner_class"))
        classBox:AddChoice("dbs_money_printer")
        classBox:AddChoice("dbs_coke_printer")
        classBox:AddChoice("dbs_coke_drying_table")
        classBox:AddChoice("dbs_coke_brick_packer")
        classBox.OnSelect = function(_, _, val) RunConsoleCommand("dbs_buyable_spawner_class", val) end

        local teamBox = vgui.Create("DComboBox", fr)
        teamBox:Dock(TOP)
        teamBox:DockMargin(8, 2, 8, 6)
        teamBox:SetValue("Team: " .. GetConVarString("dbs_buyable_spawner_team"))
        teamBox:AddChoice("Red", tostring(DBS.Const.Teams.RED))
        teamBox:AddChoice("Blue", tostring(DBS.Const.Teams.BLUE))
        teamBox:AddChoice("Police", tostring(DBS.Const.Teams.POLICE))
        teamBox.OnSelect = function(_, _, _, data)
            RunConsoleCommand("dbs_buyable_spawner_team", tostring(data))
            teamBox:SetValue("Team: " .. tostring(data))
        end

        local function addNum(label, cvar)
            local row = vgui.Create("DPanel", fr)
            row:Dock(TOP)
            row:DockMargin(8, 2, 8, 2)
            row:SetTall(24)
            row.Paint = nil
            local l = vgui.Create("DLabel", row)
            l:Dock(LEFT)
            l:SetWide(140)
            l:SetText(label)
            local e = vgui.Create("DTextEntry", row)
            e:Dock(FILL)
            e:SetText(GetConVarString(cvar))
            e.OnEnter = function(self) RunConsoleCommand(cvar, self:GetValue()) end
        end

        addNum("Price", "dbs_buyable_spawner_price")
        addNum("Dealer #", "dbs_buyable_spawner_dealer")
        addNum("Max Count", "dbs_buyable_spawner_count")
        addNum("Height Offset", "dbs_buyable_spawner_height")
        return true
    end

    function TOOL:Think()
        local tr = LocalPlayer():GetEyeTrace()
        if not tr.Hit then return end

        local class = self:GetClientInfo("class")
        local models = {
            dbs_money_printer = "models/props_c17/consolebox01a.mdl",
            dbs_coke_printer = "models/props_c17/TrapPropeller_Engine.mdl",
            dbs_coke_drying_table = "models/props_c17/FurnitureTable002a.mdl",
            dbs_coke_brick_packer = "models/hunter/blocks/cube025x05x025.mdl"
        }
        local mdl = models[class] or "models/props_c17/consolebox01a.mdl"

        if not IsValid(self.GhostEntity) then
            self:MakeGhostEntity(mdl, Vector(), Angle())
        end

        if IsValid(self.GhostEntity) then
            local height = tonumber(self:GetClientInfo("height")) or 12
            self.GhostEntity:SetModel(mdl)
            self.GhostEntity:SetPos(tr.HitPos + Vector(0,0,height))
            self.GhostEntity:SetAngles(Angle(0, LocalPlayer():EyeAngles().y, 0))
        end
    end
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Configure utility spots by team + dealer number. Left click Eli to set its dealer number." })
end
