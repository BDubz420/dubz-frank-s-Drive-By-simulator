TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Vehicle Ambient Spawns"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["max"] = "10"
TOOL.ClientConVar["interval"] = "18"
TOOL.ClientConVar["height"] = "8"
TOOL.ClientConVar["allowed"] = "" -- csv stock indices, empty = all

if CLIENT then
    language.Add("tool.dbs_vehicle_spawns.name", "DBS Vehicle Ambient Spawns")
    language.Add("tool.dbs_vehicle_spawns.desc", "Place and tune random ambient car spawn points")
    language.Add("tool.dbs_vehicle_spawns.0", "Left click: add spawn | Right click: remove nearest | Reload: apply max/interval/allowed cars")
end

function TOOL:LeftClick(tr)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end
    if not tr.Hit then return false end
    if not DBS.CarMarket or not DBS.CarMarket.AddAmbientSpawn then return false end

    local height = tonumber(self:GetClientInfo("height")) or 8
    local pos = tr.HitPos + Vector(0, 0, height)
    local ang = Angle(0, ply:EyeAngles().y, 0)
    DBS.CarMarket.AddAmbientSpawn(pos, ang)
    DBS.Util.Notify(ply, "Added ambient vehicle spawn point.")
    return true
end

function TOOL:RightClick(tr)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end
    if not tr.Hit then return false end
    if not DBS.CarMarket or not DBS.CarMarket.RemoveNearestAmbientSpawn then return false end

    local ok = DBS.CarMarket.RemoveNearestAmbientSpawn(tr.HitPos)
    DBS.Util.Notify(ply, ok and "Removed nearest ambient vehicle spawn." or "No nearby ambient spawn found.")
    return true
end

function TOOL:Reload()
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end
    if not DBS.CarMarket or not DBS.CarMarket.SetAmbientSettings then return false end

    local maxCount = tonumber(self:GetClientInfo("max")) or 10
    local interval = tonumber(self:GetClientInfo("interval")) or 18
    local allowedCsv = string.Trim(self:GetClientInfo("allowed") or "")
    local allowed = {}
    if allowedCsv ~= "" then
        for token in string.gmatch(allowedCsv, "[^,]+") do
            allowed[#allowed + 1] = tonumber(string.Trim(token)) or 0
        end
    end

    DBS.CarMarket.SetAmbientSettings(maxCount, interval)
    if DBS.CarMarket.SetAmbientAllowed then DBS.CarMarket.SetAmbientAllowed(allowed) end
    DBS.Util.Notify(ply, ("Ambient settings applied: max %d, interval %.1fs."):format(maxCount, interval))
    return true
end

if CLIENT then
    function TOOL:Think()
        local tr = LocalPlayer():GetEyeTrace()
        if not tr.Hit then return end

        if not IsValid(self.GhostEntity) then
            self:MakeGhostEntity("models/buggy.mdl", Vector(), Angle())
        end

        if IsValid(self.GhostEntity) then
            local height = tonumber(self:GetClientInfo("height")) or 8
            self.GhostEntity:SetModel("models/buggy.mdl")
            self.GhostEntity:SetPos(tr.HitPos + Vector(0, 0, height))
            self.GhostEntity:SetAngles(Angle(0, LocalPlayer():EyeAngles().y, 0))
        end
    end
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Tune ambient spawns and optionally restrict which stock car indexes are allowed to spawn." })
    panel:NumSlider("Max Ambient Cars", "dbs_vehicle_spawns_max", 0, 64, 0)
    panel:NumSlider("Spawn Interval (s)", "dbs_vehicle_spawns_interval", 8, 120, 1)
    panel:NumSlider("Height Offset", "dbs_vehicle_spawns_height", 0, 64, 0)
    panel:TextEntry("Allowed Stock Indexes CSV (e.g. 1,2,5)", "dbs_vehicle_spawns_allowed")
end
