DBS = DBS or {}
DBS.Territories = DBS.Territories or {}

DBS.Territories.List = DBS.Territories.List or {}

-- Territory states
DBS.TERRITORY_NEUTRAL   = 0
DBS.TERRITORY_RED       = 1
DBS.TERRITORY_BLUE      = 2
DBS.TERRITORY_CONTESTED = 3

-- Default config
DBS.Territories.Config = {
    ClaimCost = 5000,
    ClaimTimeMin = 60,
    ClaimTimeMax = 180,
    DecayTime = 300
}

-- Helper
function DBS.Territories.GetOwnerName(owner)
    if owner == DBS.TERRITORY_RED then return "Red"
    elseif owner == DBS.TERRITORY_BLUE then return "Blue"
    else return "Neutral" end
end
