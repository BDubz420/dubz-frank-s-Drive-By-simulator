DBS.Const = DBS.Const or {}

-- =========================
-- Teams
-- =========================
DBS.Const.Teams = {
    RED     = 1,
    BLUE    = 2,
    POLICE  = 3
}

-- =========================
-- CRED Tiers
-- =========================
DBS.Const.CredTiers = {
    GANG = {
        [0] = "Thug",
        [1] = "Hoodlum",
        [2] = "Gangster",
        [3] = "OG",
        [4] = "Hitman"
    },

    POLICE = {
        [0] = "Recruit",
        [1] = "Officer"
    }
}

-- =========================
-- Territory States
-- =========================
DBS.Const.TerritoryState = {
    NEUTRAL    = 0,
    OWNED      = 1,
    CONTESTED  = 2
}

-- =========================
-- Inventory
-- =========================
DBS.Const.Inventory = {
    MAX_SLOTS = 4
}

-- =========================
-- Team Name Mapping (Map / NPC KV support)
-- =========================
DBS.Const.TeamNames = {
    red    = DBS.Const.Teams.RED,
    blue   = DBS.Const.Teams.BLUE,
    police = DBS.Const.Teams.POLICE
}