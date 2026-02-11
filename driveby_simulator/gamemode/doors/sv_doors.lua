DBS = DBS or {}
DBS.Doors = DBS.Doors or {}

util.AddNetworkString("DBS_Doors_OpenMenu")
util.AddNetworkString("DBS_Doors_Action")

local DATA_DIR = "dbs"
local DATA_FILE = DATA_DIR .. "/doors_" .. game.GetMap() .. ".json"

DBS.Doors.PersistentOwners = DBS.Doors.PersistentOwners or {}

local function GetCfg()
    return DBS.Config.Property and DBS.Config.Property.Door or {}
end

local function IsGangTeam(teamID)
    return teamID == DBS.Const.Teams.RED or teamID == DBS.Const.Teams.BLUE
end

local function CanAccessEnemyDoor(ply, door)
    local breachUntil = door:GetNWFloat("DBS_DoorBreachUntil", 0)
    if breachUntil > CurTime() then return true end

    if IsValid(ply) then
        local accessUntil = ply:GetNWFloat("DBS_DoorAccessUntil", 0)
        if accessUntil > CurTime() then return true end
    end

    return false
end

local function EnsureDoorUnlocked(door)
    if not IsValid(door) then return end

    door:Fire("Unlock", "", 0)
    door:SetSaveValue("m_bLocked", false)
end

local function SaveDoorData()
    if not file.IsDir(DATA_DIR, "DATA") then
        file.CreateDir(DATA_DIR)
    end

    file.Write(DATA_FILE, util.TableToJSON(DBS.Doors.PersistentOwners, true))
end

local function LoadDoorData()
    if not file.Exists(DATA_FILE, "DATA") then
        DBS.Doors.PersistentOwners = {}
        return
    end

    local parsed = util.JSONToTable(file.Read(DATA_FILE, "DATA") or "")
    DBS.Doors.PersistentOwners = istable(parsed) and parsed or {}
end

function DBS.Doors.SetOwner(door, ownerTeam, shouldPersist)
    if not IsValid(door) then return end

    ownerTeam = ownerTeam or 0

    door:SetNWInt("DBS_DoorOwner", ownerTeam)

    if ownerTeam == 0 then
        door:SetColor(Color(255, 255, 255))
    else
        local c = DBS.Doors.GetTeamColor(ownerTeam)
        door:SetColor(Color(c.r, c.g, c.b, 255))
    end

    door:SetRenderMode(RENDERMODE_NORMAL)

    if shouldPersist then
        local id = DBS.Doors.GetDoorID(door)
        if id then
            DBS.Doors.PersistentOwners[id] = ownerTeam
            SaveDoorData()
        end
    end
end

function DBS.Doors.GetPriceInfo()
    local cfg = GetCfg()
    local buyPrice = cfg.BuyCost or 0
    local refund = math.floor((cfg.BuyCost or 0) * (cfg.SellRefundPercent or 0))
    return buyPrice, refund
end

local function TryBuyDoor(ply, door)
    local cfg = GetCfg()
    local plyTeam = ply:Team()

    if cfg.RequireGangTeam and not IsGangTeam(plyTeam) then
        DBS.Util.Notify(ply, "Only gangs can buy these properties.")
        return
    end

    local ownerTeam = DBS.Doors.GetOwnerTeam(door)
    if ownerTeam ~= 0 and ownerTeam ~= plyTeam then
        DBS.Util.Notify(ply, "Enemy control. You can't buy this right now.")
        return
    end

    if ownerTeam == plyTeam then
        DBS.Util.Notify(ply, "Your side already owns this property.")
        return
    end

    local buyPrice = DBS.Doors.GetPriceInfo()
    if not ply:CanAfford(buyPrice) then
        DBS.Util.Notify(ply, "You cannot afford this property.")
        return
    end

    ply:AddMoney(-buyPrice)
    DBS.Doors.SetOwner(door, plyTeam, false)
    DBS.Util.Notify(ply, "Property bought for $" .. string.Comma(buyPrice) .. ".")
end

local function TrySellDoor(ply, door)
    local ownerTeam = DBS.Doors.GetOwnerTeam(door)

    if ownerTeam == 0 then
        DBS.Util.Notify(ply, "This property is already unowned.")
        return
    end

    if ownerTeam ~= ply:Team() then
        DBS.Util.Notify(ply, "You don't own this property.")
        return
    end

    local _, refund = DBS.Doors.GetPriceInfo()
    DBS.Doors.SetOwner(door, 0, false)
    ply:AddMoney(refund)
    DBS.Util.Notify(ply, "Property sold for $" .. string.Comma(refund) .. ".")
end

local function ApplyPersistentOwners()
    for _, ent in ipairs(ents.GetAll()) do
        if not DBS.Doors.IsDoor(ent) then continue end

        EnsureDoorUnlocked(ent)

        local id = DBS.Doors.GetDoorID(ent)
        local owner = id and DBS.Doors.PersistentOwners[id] or 0
        DBS.Doors.SetOwner(ent, tonumber(owner) or 0, false)
    end
end

hook.Add("PlayerUse", "DBS.Doors.UseRestrictions", function(ply, ent)
    if not DBS.Doors.IsDoor(ent) then return end

    local owner = DBS.Doors.GetOwnerTeam(ent)
    if owner ~= 0 and owner ~= ply:Team() and not CanAccessEnemyDoor(ply, ent) then
        DBS.Util.Notify(ply, "Locked by " .. team.GetName(owner) .. ".")
        return false
    end
end)

hook.Add("InitPostEntity", "DBS.Doors.LoadAndApply", function()
    LoadDoorData()
    ApplyPersistentOwners()
end)

net.Receive("DBS_Doors_Action", function(_, ply)
    if not IsValid(ply) then return end

    local door = net.ReadEntity()
    local action = net.ReadString()

    if not IsValid(door) or not DBS.Doors.IsDoor(door) then return end

    local cfg = GetCfg()
    local maxDist = cfg.InteractionDistance or 140
    if ply:GetPos():DistToSqr(door:GetPos()) > (maxDist * maxDist) then return end

    local econCooldown = DBS.Config.Economy and DBS.Config.Economy.TransactionCooldown or 0.25
    local interactionCooldown = math.max(cfg.InteractionCooldown or 0.35, econCooldown)
    if not ply:CanRunEconomyAction(interactionCooldown) then return end

    if action == "buy" then
        TryBuyDoor(ply, door)
        return
    end

    if action == "sell" then
        TrySellDoor(ply, door)
        return
    end

    if not ply:IsAdmin() then return end

    local adminTeamMap = {
        set_red = DBS.Const.Teams.RED,
        set_blue = DBS.Const.Teams.BLUE,
        set_police = DBS.Const.Teams.POLICE,
        set_unowned = 0
    }

    local targetTeam = adminTeamMap[action]
    if targetTeam == nil then return end

    DBS.Doors.SetOwner(door, targetTeam, true)
    DBS.Util.Notify(ply, "Door ownership saved: " .. DBS.Doors.GetOwnerLabel(targetTeam))
end)
