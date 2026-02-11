DBS = DBS or {}
DBS.Doors = DBS.Doors or {}

local function GetCfg()
    return DBS.Config.Property and DBS.Config.Property.Door or {}
end

local function IsGangTeam(teamID)
    return teamID == DBS.Const.Teams.RED or teamID == DBS.Const.Teams.BLUE
end

local function IsOwnedByEnemy(ply, door)
    local ownerTeam = DBS.Doors.GetOwnerTeam(door)
    return ownerTeam ~= 0 and ownerTeam ~= ply:Team()
end

function DBS.Doors.SetOwner(door, ownerTeam)
    if not IsValid(door) then return end

    door:SetNWInt("DBS_DoorOwner", ownerTeam)

    if ownerTeam == 0 then
        door:SetColor(Color(255, 255, 255))
        door:SetRenderMode(RENDERMODE_NORMAL)
        return
    end

    local c = DBS.Doors.GetTeamColor(ownerTeam)
    door:SetColor(Color(c.r, c.g, c.b, 255))
    door:SetRenderMode(RENDERMODE_NORMAL)
end

local function TryBuyDoor(ply, door)
    local cfg = GetCfg()
    local plyTeam = ply:Team()

    if cfg.RequireGangTeam and not IsGangTeam(plyTeam) then
        DBS.Util.Notify(ply, "Only gangs can own properties.")
        return
    end

    if IsOwnedByEnemy(ply, door) then
        DBS.Util.Notify(ply, "Enemy gang owns this property.")
        return
    end

    local ownerTeam = DBS.Doors.GetOwnerTeam(door)
    if ownerTeam == plyTeam then
        DBS.Util.Notify(ply, "Your gang already owns this property.")
        return
    end

    local price = cfg.BuyCost or 0
    if not ply:CanAfford(price) then
        DBS.Util.Notify(ply, "You cannot afford this property.")
        return
    end

    ply:AddMoney(-price)
    DBS.Doors.SetOwner(door, plyTeam)

    DBS.Util.Notify(ply, "Property purchased for $" .. string.Comma(price) .. ".")
end

local function TrySellDoor(ply, door)
    local cfg = GetCfg()
    local ownerTeam = DBS.Doors.GetOwnerTeam(door)

    if ownerTeam == 0 then
        DBS.Util.Notify(ply, "This property is not owned.")
        return
    end

    if ownerTeam ~= ply:Team() then
        DBS.Util.Notify(ply, "Your gang does not own this property.")
        return
    end

    local basePrice = cfg.BuyCost or 0
    local refundPct = cfg.SellRefundPercent or 0
    local refund = math.floor(basePrice * refundPct)

    DBS.Doors.SetOwner(door, 0)
    ply:AddMoney(refund)
    DBS.Util.Notify(ply, "Property sold for $" .. string.Comma(refund) .. ".")
end

hook.Add("PlayerUse", "DBS.Doors.UseRestrictions", function(ply, ent)
    if not DBS.Doors.IsDoor(ent) then return end

    local owner = DBS.Doors.GetOwnerTeam(ent)
    if owner ~= 0 and owner ~= ply:Team() then
        DBS.Util.Notify(ply, "This property is controlled by " .. team.GetName(owner) .. ".")
        return false
    end
end)

hook.Add("KeyPress", "DBS.Doors.Interact", function(ply, key)
    if key ~= IN_USE then return end

    local cfg = GetCfg()
    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then return end

    local door = tr.Entity
    if not DBS.Doors.IsDoor(door) then return end

    local maxDist = cfg.InteractionDistance or 140
    if ply:GetPos():DistToSqr(door:GetPos()) > (maxDist * maxDist) then return end

    local econCooldown = DBS.Config.Economy and DBS.Config.Economy.TransactionCooldown or 0.25
    local interactionCooldown = math.max(cfg.InteractionCooldown or 0.35, econCooldown)

    if not ply:CanRunEconomyAction(interactionCooldown) then return end

    if ply:KeyDown(IN_SPEED) then
        TrySellDoor(ply, door)
    else
        TryBuyDoor(ply, door)
    end
end)

hook.Add("InitPostEntity", "DBS.Doors.InitializeDoorState", function()
    for _, ent in ipairs(ents.GetAll()) do
        if DBS.Doors.IsDoor(ent) then
            DBS.Doors.SetOwner(ent, 0)
        end
    end
end)
