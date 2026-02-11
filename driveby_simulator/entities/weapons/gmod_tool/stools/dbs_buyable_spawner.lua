TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Buyable Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["class"] = "dbs_money_printer"

if CLIENT then
    language.Add("tool.dbs_buyable_spawner.name", "DBS Buyable Spawner")
    language.Add("tool.dbs_buyable_spawner.desc", "Mark HQ static spawn spots for buyable dealer entities")
    language.Add("tool.dbs_buyable_spawner.0", "Left click: set spot for your team and selected class")
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

    DBS.Eli.SetBuyableSpot(ply:Team(), class, tr.HitPos + tr.HitNormal * 2, tr.HitNormal:Angle())
    DBS.Util.Notify(ply, "Set buyable spot for team " .. ply:Team() .. " class " .. class .. ".")
    return true
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Set static HQ spots for utility buys." })
    panel:AddControl("ComboBox", {
        MenuButton = 0,
        Folder = "dbs_buyable_spawner",
        Options = {
            ["Money Printer"] = { dbs_buyable_spawner_class = "dbs_money_printer" },
            ["Coke Printer"] = { dbs_buyable_spawner_class = "dbs_coke_printer" }
        }
    })
end
