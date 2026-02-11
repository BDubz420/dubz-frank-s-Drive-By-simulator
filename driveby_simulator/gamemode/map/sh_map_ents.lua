DBS = DBS or {}
DBS.MapEnts = DBS.MapEnts or {}

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

for _, e in ipairs(TerritoryDefaults) do
    DBS.MapEnts.List[#DBS.MapEnts.List + 1] = e
end
