DBS = DBS or {}
DBS.MapEnts = DBS.MapEnts or {}

local function BuildNPCEntries()
    local entries = {}
    local cfg = DBS.Config and DBS.Config.NPC and DBS.Config.NPC.Spawns

    if not cfg then return entries end

    if cfg.TeamSelector then
        entries[#entries + 1] = {
            class = "dbs_npc_jerome",
            pos = cfg.TeamSelector.Pos,
            ang = cfg.TeamSelector.Ang or Angle(0, 0, 0)
        }
    end

    for _, d in ipairs(cfg.Dealers or {}) do
        entries[#entries + 1] = {
            class = "dbs_npc_eli",
            pos = d.Pos,
            ang = d.Ang or Angle(0, 0, 0),
            kv = { team = d.Team }
        }
    end

    if cfg.PickpocketTrainer then
        entries[#entries + 1] = {
            class = "dbs_npc_pickpocket_trainer",
            pos = cfg.PickpocketTrainer.Pos,
            ang = cfg.PickpocketTrainer.Ang or Angle(0, 0, 0)
        }
    end

    if cfg.Judge then
        entries[#entries + 1] = {
            class = "dbs_npc_judge",
            pos = cfg.Judge.Pos,
            ang = cfg.Judge.Ang or Angle(0, 0, 0)
        }
    end

    if cfg.CarDealer then
        entries[#entries + 1] = { class = "dbs_npc_car_dealer", pos = cfg.CarDealer.Pos, ang = cfg.CarDealer.Ang or Angle(0,0,0) }
    end

    if cfg.DrugDealer then
        entries[#entries + 1] = { class = "dbs_npc_drug_dealer", pos = cfg.DrugDealer.Pos, ang = cfg.DrugDealer.Ang or Angle(0,0,0) }
    end

    for _, box in ipairs(cfg.DrugDropboxes or {}) do
        entries[#entries + 1] = { class = "dbs_drug_dropbox", pos = box.Pos, ang = box.Ang or Angle(0,0,0) }
    end

    return entries
end

local TerritoryDefaults = {
    { class = "dbs_territory_pole", pos = Vector(3420, 1313, 64), ang = Angle(0, 0, 0) },
    { class = "dbs_territory_pole", pos = Vector(-1008, -1188, 64), ang = Angle(0, 0, 0) },
    { class = "dbs_territory_pole", pos = Vector(-762, 868, 64), ang = Angle(0, 0, 0) },
    { class = "dbs_territory_pole", pos = Vector(2153, -2724, 64), ang = Angle(0, 0, 0) },
    { class = "dbs_territory_pole", pos = Vector(9641, -3953, 64), ang = Angle(0, 0, 0) },
    { class = "dbs_territory_pole", pos = Vector(5352, -4039, 72), ang = Angle(0, 0, 0) },
    { class = "dbs_territory_pole", pos = Vector(4973, -1736, 72), ang = Angle(0, 0, 0) },
    { class = "dbs_territory_pole", pos = Vector(1115, 1814, 72), ang = Angle(0, 0, 0) }
}

DBS.MapEnts.List = {}

for _, e in ipairs(BuildNPCEntries()) do
    DBS.MapEnts.List[#DBS.MapEnts.List + 1] = e
end

for _, e in ipairs(TerritoryDefaults) do
    DBS.MapEnts.List[#DBS.MapEnts.List + 1] = e
end
