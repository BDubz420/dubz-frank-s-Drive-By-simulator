TOOL.Category = "DriveBy Simulator"
TOOL.Name = "Perma Props"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("tool.dbs_permaprops.name", "DBS Perma Props")
    language.Add("tool.dbs_permaprops.desc", "Save placed entities to respawn on map start/cleanup")
    language.Add("tool.dbs_permaprops.0", "Left click: save looked-at entity | Right click: remove nearest saved prop and entity")
end

function TOOL:LeftClick(tr)
    if CLIENT then return true end
    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end

    local ent = tr.Entity
    if not IsValid(ent) then return false end

    if not DBS.PermaProps or not DBS.PermaProps.SaveEntity then
        DBS.Util.Notify(ply, "Perma prop system unavailable.")
        return false
    end

    local ok = DBS.PermaProps.SaveEntity(ent)
    DBS.Util.Notify(ply, ok and "Saved entity to PermaProps." or "Could not save this entity.")
    return ok
end

function TOOL:RightClick(tr)
    if CLIENT then return true end
    local ply = self:GetOwner()
    if not IsValid(ply) or not ply:IsAdmin() then return false end

    if not DBS.PermaProps or not DBS.PermaProps.RemoveNear then
        DBS.Util.Notify(ply, "Perma prop system unavailable.")
        return false
    end

    local hitPos = tr.HitPos
    if IsValid(tr.Entity) then
        hitPos = tr.Entity:GetPos()
    end

    local ok = DBS.PermaProps.RemoveNear(hitPos, true)
    if IsValid(tr.Entity) and tr.Entity:GetNWBool("DBS_PermaProp", false) then
        tr.Entity:Remove()
        ok = true
    end

    DBS.Util.Notify(ply, ok and "Removed nearest saved permaprop and world entity." or "No saved permaprop nearby.")
    return ok
end

if CLIENT then
    hook.Add("PreDrawHalos", "DBS.PermaPropHalos", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
        local tool = LocalPlayer():GetTool()
        if not tool or tool.Mode ~= "dbs_permaprops" then return end

        local entsToHalo = {}
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent:GetNWBool("DBS_PermaProp", false) then
                entsToHalo[#entsToHalo + 1] = ent
            end
        end

        if #entsToHalo > 0 then
            halo.Add(entsToHalo, Color(120, 220, 255), 1, 1, 1, true, true)
        end
    end)
end

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", { Description = "Save placed map entities so they auto-respawn on map start/cleanup." })
end
