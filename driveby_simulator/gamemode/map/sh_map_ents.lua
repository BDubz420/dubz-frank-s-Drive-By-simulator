-- gamemode/map/sh_map_ents.lua
DBS = DBS or {}
DBS.MapEnts = DBS.MapEnts or {}

DBS.MapEnts.List = {
    -- Team Selection
    {
        class = "dbs_npc_jerome",
        pos   = Vector(2377, 1698, 128),
        ang   = Angle(0, 90, 0),
    },
    -- Dealers
    {
        class = "dbs_npc_eli",
        pos   = Vector(2674, -577, 80),
        ang   = Angle(0, 180, 0),
        kv    = { team = "red" }
    },
    {
        class = "dbs_npc_eli",
        pos   = Vector(10192, -2952, 72),
        ang   = Angle(0, 0, 0),
        kv    = { team = "blue" }
    },
    {
        class = "dbs_npc_eli",
        pos   = Vector(4161, -613, 72),
        ang   = Angle(0, 0, 0),
        kv    = { team = "police" }
    },
    -- Pickpocket Trainer
    {
        class = "dbs_npc_pickpocket_trainer",
        pos   = Vector(2465, 1735, 128),
        ang   = Angle(0, 180, 0),
    },

    -- Territories
    {
        class = "dbs_territory_pole",
        pos   = Vector(3420, 1313, 64),
        ang   = Angle(0, 0, 0)
    },
    {
        class = "dbs_territory_pole",
        pos   = Vector(-1008, -1188, 64),
        ang   = Angle(0, 0, 0)
    },
    {
        class = "dbs_territory_pole",
        pos   = Vector(-762, 868, 64),
        ang   = Angle(0, 0, 0)
    },
    {
        class = "dbs_territory_pole",
        pos   = Vector(2153, -2724, 64),
        ang   = Angle(0, 0, 0)
    },
    {
        class = "dbs_territory_pole",
        pos   = Vector(9641, -3953, 64),
        ang   = Angle(0, 0, 0)
    },
    {
        class = "dbs_territory_pole",
        pos   = Vector(5352, -4039, 72),
        ang   = Angle(0, 0, 0)
    },
    {
        class = "dbs_territory_pole",
        pos   = Vector(4973, -1736, 72),
        ang   = Angle(0, 0, 0)
    },
    {
        class = "dbs_territory_pole",
        pos   = Vector(1115, 1814, 72),
        ang   = Angle(0, 0, 0)
    },
}


-- Territories

-- setpos 3420.849121 1313.351562 128.031250;setang 9.982113 -89.818230 0.000000 -- Brick houses
-- setpos -1008.073242 -1188.686523 128.031250;setang 4.145068 -0.083531 0.000000 -- Map Spawn
-- setpos -762.951721 868.352539 128.031250;setang 10.018805 -10.192720 0.000000 -- Park
-- setpos 2153.759766 -2724.514404 128.031250;setang 8.537767 91.803940 0.000000 -- Yard
-- setpos 9641.060547 -3953.666016 128.031250;setang 4.704491 88.211494 0.000000 -- Blue HQ
-- setpos 5352.717285 -4039.336426 136.031250;setang 3.223452 103.329582 0.000000 -- Alleys
-- setpos 4973.374023 -1736.700928 136.031250;setang -0.958297 177.990753 0.000000 -- Appartments
-- setpos 1115.987305 1814.816895 136.031250;setang 1.393940 89.281181 0.000000 -- Courthouse

