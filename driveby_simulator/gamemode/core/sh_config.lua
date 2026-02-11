DBS.Config = DBS.Config or {}

-- =========================
-- CORE RULES (Simple)
-- =========================
DBS.Config.Core = {
    StartingMoney = 0,
    StartingCred  = 0,

    MaxCredGang   = 4,
    MaxCredPolice = 1,

    InventorySlots = 4
}

-- =========================
-- CRED RULES
-- =========================
DBS.Config.Cred = {
    KillsPerCred = 5,

    PoliceUnclaimCred = 1
}

-- =========================
-- CAR RULES
-- =========================
DBS.Config.Cars = {
    LockpickTime = 3,
    LoudLockpick = true,

    Reward = {
        NeutralCarMoney = 100,
        EnemyCarMoney   = 100,
        EnemyCarCred    = 1,
        HQDeliveryMoney = 100
    }
}

-- =========================
-- TERRITORY RULES
-- =========================
DBS.Config.Territory = {
    CaptureCost = 5000,

    CaptureTimeMin = 60,
    CaptureTimeMax = 180,

    DecayTime = 300, -- 5 minutes

    ContestEnabled = true
}

-- =========================
-- PACKAGE SYSTEM
-- =========================
DBS.Config.Package = {
    BuyPrice = 2500,

    Machine = {
        RefillCost = 2500,
        PackagesPerRefill = 2,
        ProductionTime = 300
    }
}

-- =========================
-- PROPERTY / MACHINES
-- =========================
DBS.Config.Property = {
    BuyCost = 5000
}

DBS.Config.GunTable = {
    UseCost = 5000,
    CraftTime = 300,
    MaxCredAllowed = 3
}

-- =========================
-- POLICE / COURT
-- =========================
DBS.Config.Court = {
    KillsPerMinute = 2,
    MaxMinutes = 5,
    EscapeGuessMin = 1,
    EscapeGuessMax = 12
}

-- =========================
-- DAY / NIGHT
-- =========================
DBS.Config.Time = {
    NightBias = 0.65 -- > 0.5 = longer nights
}

-- =========================
-- SPAWNS (Map-specific)
-- Prefer entity names if your map has them.
-- Fallback to vectors.
-- =========================
DBS.Config.Spawns = {
    Intro = {
        EntName = "dbs_spawn_intro", -- optional map entity name
        Pos = Vector(2387, 1943, 128),
        Ang = Angle(0, -90, 0)
    },

    HQ = {
        [DBS.Const.Teams.RED] = {
            EntName = "dbs_spawn_red_hq",
            Pos = Vector(2551, -570, 144),
            Ang = Angle(0, 180, 0),

            -- Used for car delivery detection in Phase 2.2
            DeliveryPos = Vector(0, 0, 0),
            DeliveryRadius = 220
        },
        [DBS.Const.Teams.BLUE] = {
            EntName = "dbs_spawn_blue_hq",
            Pos = Vector(10249, -3783, 136),
            Ang = Angle(0, 90, 0),

            DeliveryPos = Vector(0, 0, 0),
            DeliveryRadius = 220
        },
        [DBS.Const.Teams.POLICE] = {
            EntName = "dbs_spawn_police_hq",
            Pos = Vector(4249, -636, 136),
            Ang = Angle(0, 90, 0)
        }
    }
}

DBS.Config.PlayerModels = {
    [0] = { -- Unassigned
        "models/player/group01/male_01.mdl",
        "models/player/group01/male_02.mdl",
        "models/player/group01/male_03.mdl"
    },

    [DBS.Const.Teams.RED] = {
        "models/player/group03/male_01.mdl",
        "models/player/group03/male_02.mdl",
        "models/player/group03/male_03.mdl",
    },

    [DBS.Const.Teams.BLUE] = {
        "models/player/group03/male_04.mdl",
        "models/player/group03/male_05.mdl",
        "models/player/group03/male_06.mdl",
    },

    [DBS.Const.Teams.POLICE] = {
        "models/player/police.mdl",
        "models/player/police_fem.mdl"
    }
}
-- =========================
-- VEHICLES
-- =========================
DBS.Config.Vehicles = {
    ScanClasses = {
        "prop_vehicle_jeep",
        "prop_vehicle_airboat",
        "prop_vehicle_prisoner_pod"
    },

    RespawnDestroyed = true,
    RespawnDelay = 12,

    -- If you want conversion to set vehicle color
    UseTeamColors = true
}

DBS.Config.WeaponDropBlacklist = {
    ["weapon_fists"] = true,
    ["weapon_dbs_hands"] = true,
    ["weapon_dbs_lockpick"] = true,
}

-- =========================
-- SHOPS (Eli + Police Armorer)
-- NOTE: Weapon class names are placeholders. Replace with your SWEP classes.
-- =========================
DBS.Config.Shop = {
    Gang = {
        CredCap = 4,

        Tiers = {
            [0] = {
                Name = "Thug",
                Items = {
                    { Name = "Knife", Class = "tfa_nmrih_kknife", Price = 150 },
                    { Name = "Colt 1911",  Class = "tfa_colt1911", Price = 250 },
                }
            },
            [1] = {
                Name = "Hoodlum",
                Items = {
                    { Name = "P229r", Class = "tfa_sig_p229r", Price = 350 },
                    { Name = "M92 Beretta",  Class = "tfa_m92beretta", Price = 500 },
                    { Name = "Tec9", Class = "tfa_tec9",   Price = 500 },
                }
            },
            [2] = {
                Name = "Gangster",
                Items = {
                    { Name = "UZI",      Class = "tfa_uzi",  Price = 800 },
                    { Name = "AK47",     Class = "tfa_ak47",   Price = 1200 },
                    { Name = "Mossberg 590", Class = "tfa_mossberg590", Price = 1500 },
                }
            },
            [3] = {
                Name = "OG",
                Items = {
                    { Name = "M4A1 ACOG", Class = "tfa_m16a4_acog", Price = 3000 },
                    { Name = "Glock",     Class = "tfa_glock", Price = 1500 },
                    { Name = "MP5",       Class = "tfa_mp5", Price = 2500 },
                }
            },
            [4] = {
                Name = "Hitman",
                Items = {
                    { Name = "MP9",   Class = "tfa_mp9", Price = 3500 },
                    { Name = "AS VAL",Class = "tfa_val",  Price = 5000 },
                    { Name = "MP5SD", Class = "tfa_mp5sd", Price = 4000 },
                }
            }
        },

        SellPrices = {
            ["weapon_stunstick"]    = 20,
            ["tfa_nmrih_kknife"]    = 100,
            ["tfa_colt1911"]        = 120,
            ["tfa_sig_p229r"]       = 80,
            ["tfa_m92beretta"]      = 150,
            ["tfa_tec9"]            = 150,
            ["tfa_uzi"]             = 300,
            ["tfa_ak47"]            = 900,
            ["tfa_mossberg590"]     = 1200,
            ["tfa_m16a4_acog"]      = 2100,
            ["tfa_glock"]           = 1200,
            ["tfa_mp5"]             = 2200,
            ["tfa_mp9"]             = 3100,
            ["tfa_val"]             = 4700
        }
    },

    Police = {
        CredCap = 1,

        Tiers = {
            [0] = {
                Name = "Recruit",
                Items = {
                    { Name = "Stunstick", Class = "weapon_stunstick", Price = 150 },
                    { Name = "M92",       Class = "tfa_m92beretta",    Price = 250 },
                }
            },
            [1] = {
                Name = "Officer",
                Items = {
                    { Name = "MP5",   Class = "tfa_mp5",    Price = 800 },
                    { Name = "M4A1",  Class = "tfa_m4a1",     Price = 2000 },
                    { Name = "Ithaca",Class = "tfa_ithacam37", Price = 1500 },
                }
            }
        },

        SellPrices = {
            ["weapon_stunstick"]    = 20,
            ["tfa_nmrih_kknife"]    = 100,
            ["tfa_colt1911"]        = 120,
            ["tfa_sig_p229r"]       = 80,
            ["tfa_m92beretta"]      = 150,
            ["tfa_tec9"]            = 150,
            ["tfa_uzi"]             = 300,
            ["tfa_ak47"]            = 900,
            ["tfa_mossberg590"]     = 1200,
            ["tfa_m16a4_acog"]      = 2100,
            ["tfa_glock"]           = 1200,
            ["tfa_mp5"]             = 2200,
            ["tfa_mp9"]             = 3100,
            ["tfa_val"]             = 4700,
            ["tfa_mp5sd"]           = 3600,
            ["tfa_m4a1"]            = 1400,
            ["tfa_ithacam37"]       = 1100
        }
    }
}

DBS.Config.TerritoryPole = {
    Radius = 350,

    ContestNeutralizeTime = 25, -- seconds enemy must remain to neutralize owned pole
    CaptureCancelOnEnemy  = true,

    -- Temporary until UI exists:
    AutoClaimForNow = true
}

DBS.Config.DealerModels = {
    [DBS.Const.Teams.RED] = "models/player/bmyst.mdl",
    [DBS.Const.Teams.BLUE] = "models/CaptainBleysFire/yunomiles/Yuno_Miles.mdl",
    [DBS.Const.Teams.POLICE] = "models/player/css_koonkillaz/t_leetedge.mdl"
}
