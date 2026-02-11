-- gamemode/map/sv_map_ents.lua
DBS = DBS or {}
DBS.MapEnts = DBS.MapEnts or {}

DBS.MapEnts.Spawned = DBS.MapEnts.Spawned or {}

local function SpawnOne(id, data)
    if not data.class or not data.pos then return end

    local ent = ents.Create(data.class)
    if not IsValid(ent) then
        print("[DBS] Failed to spawn entity:", data.class)
        return
    end

    ent:SetPos(data.pos)
    ent:SetAngles(data.ang or Angle(0,0,0))

    -- Optional keyvalues
    if istable(data.kv) then
        for k, v in pairs(data.kv) do
            ent:SetKeyValue(k, tostring(v))
        end
    end

    ent:Spawn()
    ent:Activate()

    DBS.MapEnts.Spawned[id] = ent
end

function DBS.MapEnts.SpawnAll()
    DBS.MapEnts.Spawned = {}

    for id, data in ipairs(DBS.MapEnts.List or {}) do
        SpawnOne(id, data)
    end

    print("[DBS] Spawned", table.Count(DBS.MapEnts.Spawned), "map entities")
end

-- Hook into map load
hook.Add("InitPostEntity", "DBS.SpawnMapEntities", function()
    DBS.MapEnts.SpawnAll()
end)
