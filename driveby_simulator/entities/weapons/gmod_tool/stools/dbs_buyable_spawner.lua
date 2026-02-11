TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Buyable Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["class"] = "dbs_money_printer"
TOOL.ClientConVar["price"] = "3000"
TOOL.ClientConVar["dealer"] = "1"
TOOL.ClientConVar["count"] = "1"
TOOL.ClientConVar["height"] = "12"

if CLIENT then
    language.Add("tool.dbs_buyable_spawner.name", "DBS Buyable Spawner")
    language.Add("tool.dbs_buyable_spawner.desc", "Mark HQ static spawn spots for buyable dealer entities")
    language.Add("tool.dbs_buyable_spawner.0", "Left click: set spot | Right click: open config menu")
end

local VALID = {
    ["dbs_money_printer"] = true,
    ["dbs_coke_printer"] = true
}

function TOOL:LeftClick(tr)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end
    if not tr.Hit then return false end

    local class = self:GetClientInfo("class")
    if not VALID[class] then
        DBS.Util.Notify(ply, "Invalid class for buyable spawner.")
        return false
    end

    if not DBS.Eli or not DBS.Eli.SetBuyableSpot then
        DBS.Util.Notify(ply, "Dealer system unavailable.")
        return false
    end

    local dealer = math.max(1, tonumber(self:GetClientInfo("dealer")) or 1)
    local price = math.max(1, tonumber(self:GetClientInfo("price")) or 1000)
    local count = math.max(1, tonumber(self:GetClientInfo("count")) or 1)
    local height = tonumber(self:GetClientInfo("height")) or 12

    local ang = Angle(0, ply:EyeAngles().y, 0)
    local pos = tr.HitPos + Vector(0, 0, height)

    DBS.Eli.SetBuyableSpot(ply:Team(), class, pos, ang, dealer, price, count)
    DBS.Util.Notify(ply, ("Set dealer #%d spot for %s ($%d, max %d)." ):format(dealer, class, price, count))
    return true
end

function TOOL:RightClick()
    if SERVER then return true end

    local fr = vgui.Create("DFrame")
    fr:SetSize(320, 240)
    fr:Center()
    fr:SetTitle("DBS Buyable Spawner Config")
    fr:MakePopup()

    local classBox = vgui.Create("DComboBox", fr)
    classBox:Dock(TOP)
    classBox:DockMargin(8, 8, 8, 4)
    classBox:SetValue(GetConVarString("dbs_buyable_spawner_class"))
    classBox:AddChoice("dbs_money_printer")
    classBox:AddChoice("dbs_coke_printer")
    classBox.OnSelect = function(_, _, val) RunConsoleCommand("dbs_buyable_spawner_class", val) end

    local function addNum(label, cvar)
        local row = vgui.Create("DPanel", fr)
        row:Dock(TOP)
        row:DockMargin(8, 2, 8, 2)
        row:SetTall(24)
        row.Paint = nil
        local l = vgui.Create("DLabel", row)
        l:Dock(LEFT)
        l:SetWide(120)
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

if CLIENT then
    function TOOL:Think()
        local tr = LocalPlayer():GetEyeTrace()
        if not tr.Hit then return end

        local class = self:GetClientInfo("class")
        local mdl = class == "dbs_coke_printer" and "models/props_c17/TrapPropeller_Engine.mdl" or "models/props_c17/consolebox01a.mdl"

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
    panel:AddControl("Header", { Description = "Set static HQ spots for utility buys." })
end
