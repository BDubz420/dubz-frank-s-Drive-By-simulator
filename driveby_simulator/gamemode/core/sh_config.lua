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

    PoliceUnclaimCred = 1,
    CredForLargeDeliveryUnits = 18
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

    CaptureTimeMin = 25,
    CaptureTimeMax = 55,

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
    BuyCost = 5000,

    Door = {
        BuyCost = 1200,
        SellRefundPercent = 0.5,
        RequireGangTeam = true,
        InteractionDistance = 140,
        InteractionCooldown = 0.35,
        OverclaimMultiplier = 2.4
    }
}


DBS.Config.CarsDealer = {
    BuybackScale = 0.6,
    AmbientMax = 10,
    SpawnPositions = {
        { Pos = Vector(2500, 1600, 128), Ang = Angle(0, 90, 0) },
        { Pos = Vector(2200, 1300, 128), Ang = Angle(0, 180, 0) },
        { Pos = Vector(4800, -1800, 80), Ang = Angle(0, 30, 0) },
        { Pos = Vector(9800, -3900, 136), Ang = Angle(0, -90, 0) }
    },

    Stock = {
        { Name = "Bati 801", Class = "gtav_bati801", Model = "models/tdmcars/gtav/bati801.mdl", Price = 6200, Buyout = 9800, VehicleClass = "gtav_bati801" },
        { Name = "Blazer", Class = "gtav_blazer", Model = "models/tdmcars/gtav/blazer.mdl", Price = 4800, Buyout = 7600, VehicleClass = "gtav_blazer" },
        { Name = "Dukes", Class = "gtav_dukes", Model = "models/tdmcars/gtav/dukes.mdl", Price = 7200, Buyout = 11200, VehicleClass = "gtav_dukes" },
        { Name = "Gauntlet Classic", Class = "gtav_gauntlet_classic", Model = "models/tdmcars/gtav/gauntlet_classic.mdl", Price = 7800, Buyout = 12100, VehicleClass = "gtav_gauntlet_classic" },
        { Name = "Infernus", Class = "gtav_infernus", Model = "models/tdmcars/gtav/infernus.mdl", Price = 12000, Buyout = 18000, VehicleClass = "gtav_infernus" },
        { Name = "JB700", Class = "gtav_jb700", Model = "models/tdmcars/gtav/jb700.mdl", Price = 9200, Buyout = 14000, VehicleClass = "gtav_jb700" },
        { Name = "Speedo", Class = "gtav_speedo", Model = "models/tdmcars/gtav/speedo.mdl", Price = 5600, Buyout = 8800, VehicleClass = "gtav_speedo" },
        { Name = "Wolfsbane", Class = "gtav_wolfsbane", Model = "models/tdmcars/gtav/wolfsbane.mdl", Price = 5100, Buyout = 8000, VehicleClass = "gtav_wolfsbane" },

        { Name = "Police Cruiser", Class = "gtav_police_cruiser", Model = "models/tdmcars/gtav/police_cruiser.mdl", Price = 9800, Buyout = 15200, VehicleClass = "gtav_police_cruiser", PoliceOnly = true },
        { Name = "Insurgent", Class = "gtav_insurgent", Model = "models/tdmcars/gtav/insurgent.mdl", Price = 14500, Buyout = 22000, VehicleClass = "gtav_insurgent", PoliceOnly = true }
    }
}

DBS.Config.Printer = {
    Price = 3000,
    PrintInterval = 8,
    PrintAmount = 35,
    MaxStored = 3000,
    MaxPerPlayer = 5
}

DBS.Config.CokePrinter = {
    Price = 9500,
    MaxPerPlayer = 2
}

DBS.Config.Drugs = {
    PayoutPerUnit = 90,
    MeetDuration = 180,
    DropboxModel = "models/props_vents/vent_medium_grill002.mdl"
}

DBS.Config.Economy = {
    StipendInterval = 90,
    GangStipend = 125,
    PoliceStipend = 175,

    GangKillReward = 150,
    PoliceKillReward = 100,

    SoftWalletCap = 6000,
    SoftCapPayoutScale = 0.35,

    TransactionCooldown = 0.25
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
    JailPositions = {
        { Pos = Vector(1105, 1865, 136), Ang = Angle(0, 180, 0) }
    },
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
    [0] = { -- Unassigned (rebels)
        "models/player/group03/male_01.mdl",
        "models/player/group03/male_02.mdl",
        "models/player/group03/male_03.mdl",
        "models/player/group03/female_01.mdl"
    },

    [DBS.Const.Teams.RED] = {
        "models/player/bloodz/playermodels/bloodzpm.mdl",
        "models/player/bloodz/playermodels/bloodzpm_02.mdl",
        "models/player/group03/male_01.mdl",
    },

    [DBS.Const.Teams.BLUE] = {
        "models/player/cripz/playermodels/cripzpm.mdl",
        "models/player/cripz/playermodels/cripzpm_02.mdl",
        "models/player/group03/male_06.mdl",
    },

    [DBS.Const.Teams.POLICE] = {
        "models/player/police.mdl",
        "models/player/police_fem.mdl",
        "models/player/combine_soldier.mdl",
        "models/player/combine_soldier_prisonguard.mdl",
        "models/player/combine_super_soldier.mdl"
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



DBS.Config.Police = {
    ArrestRange = 130,
    ArrestCooldown = 1.5,
    ArrestWeaponClass = "weapon_stunstick",
    JudgeSentenceDelay = 8
}

DBS.Config.NPC = {
    Models = {
        TeamSelector = "models/Humans/Group03/male_07.mdl",
        PickpocketTrainer = "models/Humans/Group03/male_04.mdl",
        Judge = "models/Humans/Group03/male_09.mdl",
        CarDealer = "models/Humans/Group03/male_06.mdl",
        DrugDealer = "models/Humans/Group03/male_08.mdl"
    },

    Spawns = {
        TeamSelector = { Pos = Vector(2377, 1698, 128), Ang = Angle(0, 90, 0) },
        PickpocketTrainer = { Pos = Vector(2465, 1735, 128), Ang = Angle(0, 180, 0) },
        Judge = { Pos = Vector(1120, 1824, 136), Ang = Angle(0, -90, 0) },
        CarDealer = { Pos = Vector(2405, 1602, 128), Ang = Angle(0, 90, 0) },
        DrugDealer = { Pos = Vector(5300, -4020, 72), Ang = Angle(0, 180, 0) },
        DrugDropboxes = {
            { Pos = Vector(5320, -3990, 72), Ang = Angle(0, 0, 0) }
        },

        Dealers = {
            { Team = "red", Pos = Vector(2674, -577, 80), Ang = Angle(0, 180, 0) },
            { Team = "blue", Pos = Vector(10192, -2952, 72), Ang = Angle(0, 0, 0) },
            { Team = "police", Pos = Vector(4161, -613, 72), Ang = Angle(0, 0, 0) }
        }
    }
}

DBS.Config.Vulnerability = {
    KnockoutDuration = 15,
    KnockoutChanceOnFatal = 0.5
}

DBS.Config.WeaponDropBlacklist = {
    ["weapon_fists"] = true,
    ["weapon_dbs_hands"] = true,
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
    [DBS.Const.Teams.RED] = "models/Humans/Group03/male_07.mdl",
    [DBS.Const.Teams.BLUE] = "models/Humans/Group03/male_07.mdl",
    [DBS.Const.Teams.POLICE] = "models/Humans/Group03/male_07.mdl"
}
