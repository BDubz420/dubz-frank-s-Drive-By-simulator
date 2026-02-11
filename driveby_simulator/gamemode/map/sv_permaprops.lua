DBS = DBS or {}
DBS.PermaProps = DBS.PermaProps or {}

local DATA_DIR = "dbs"
local DATA_FILE = DATA_DIR .. "/permaprops_" .. game.GetMap() .. ".json"

DBS.PermaProps.List = DBS.PermaProps.List or {}

local function Save()
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
    file.Write(DATA_FILE, util.TableToJSON(DBS.PermaProps.List, true))
end

local function Load()
    if not file.Exists(DATA_FILE, "DATA") then
        DBS.PermaProps.List = {}
        return
    end

    local parsed = util.JSONToTable(file.Read(DATA_FILE, "DATA") or "")
    DBS.PermaProps.List = istable(parsed) and parsed or {}
end

local function SerializeBodygroups(ent)
    local t = {}
    local count = ent:GetNumBodyGroups() or 0
    for i = 0, count - 1 do
        t[i] = ent:GetBodygroup(i)
    end
    return t
end

local function SpawnEntry(entry)
    if not istable(entry) then return end
    local ent = ents.Create(entry.class)
    if not IsValid(ent) then return end

    if entry.model and entry.model ~= "" then ent:SetModel(entry.model) end
    ent:SetPos(Vector(entry.pos.x, entry.pos.y, entry.pos.z))
    ent:SetAngles(Angle(entry.ang.p, entry.ang.y, entry.ang.r))
    ent:Spawn()

    if entry.skin then ent:SetSkin(entry.skin) end
    if istable(entry.bodygroups) then
        for id, val in pairs(entry.bodygroups) do
            ent:SetBodygroup(tonumber(id) or 0, tonumber(val) or 0)
        end
    end

    if entry.color then
        ent:SetColor(Color(entry.color.r, entry.color.g, entry.color.b, entry.color.a or 255))
    end

    ent:SetNWBool("DBS_PermaProp", true)
end

function DBS.PermaProps.SaveEntity(ent)
    if not IsValid(ent) or ent:IsPlayer() then return false end
    if ent:GetClass() == "worldspawn" then return false end

    local pos = ent:GetPos()
    local ang = ent:GetAngles()

    DBS.PermaProps.List[#DBS.PermaProps.List + 1] = {
        class = ent:GetClass(),
        model = ent:GetModel() or "",
        pos = { x = pos.x, y = pos.y, z = pos.z },
        ang = { p = ang.p, y = ang.y, r = ang.r },
        skin = ent:GetSkin() or 0,
        bodygroups = SerializeBodygroups(ent),
        color = { r = ent:GetColor().r, g = ent:GetColor().g, b = ent:GetColor().b, a = ent:GetColor().a }
    }

    ent:SetNWBool("DBS_PermaProp", true)
    Save()
    return true
end

function DBS.PermaProps.RemoveNear(pos)
    local best, bestDist
    for i, e in ipairs(DBS.PermaProps.List) do
        local v = Vector(e.pos.x, e.pos.y, e.pos.z)
        local d = pos:DistToSqr(v)
        if not bestDist or d < bestDist then
            best, bestDist = i, d
        end
    end

    if best and bestDist and bestDist <= (280 * 280) then
        table.remove(DBS.PermaProps.List, best)
        Save()
        return true
    end

    return false
end

function DBS.PermaProps.SpawnAll()
    for _, e in ipairs(DBS.PermaProps.List) do
        SpawnEntry(e)
    end
end

hook.Add("InitPostEntity", "DBS.PermaProps.LoadSpawn", function()
    Load()
    DBS.PermaProps.SpawnAll()
end)

hook.Add("PostCleanupMap", "DBS.PermaProps.Respawn", function()
    timer.Simple(0.1, function()
        DBS.PermaProps.SpawnAll()
    end)
end)
