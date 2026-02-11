DBS = DBS or {}
DBS.Eli = DBS.Eli or {}
DBS.BuyableSpots = DBS.BuyableSpots or {}
DBS.EliDealerSpawns = DBS.EliDealerSpawns or {}
DBS.EliDealerLinks = DBS.EliDealerLinks or {}

util.AddNetworkString("DBS_Eli_Open")
util.AddNetworkString("DBS_Eli_Buy")
util.AddNetworkString("DBS_Eli_Sell")
util.AddNetworkString("DBS_Eli_BuyPrinter")
util.AddNetworkString("DBS_Eli_BuyCokePrinter")
util.AddNetworkString("DBS_Eli_BuyDryingTable")
util.AddNetworkString("DBS_Eli_BuyBrickPacker")

local SPOT_FILE = "dbs/buyable_spots_" .. game.GetMap() .. ".json"

local function DealerKey(teamID, dealerID)
    return tostring(teamID) .. ":" .. tostring(dealerID)
end

local function SpotKey(teamID, dealerID, class)
    return tostring(teamID) .. ":" .. tostring(dealerID) .. ":" .. tostring(class)
end

local function EncodeVec(v)
    return { x = v.x, y = v.y, z = v.z }
end

local function EncodeAng(a)
    return { p = a.p, y = a.y, r = a.r }
end

local function DecodeVec(t)
    if not istable(t) then return nil end
    local x, y, z = tonumber(t.x), tonumber(t.y), tonumber(t.z)
    if not x or not y or not z then return nil end
    return Vector(x, y, z)
end

local function DecodeAng(t)
    if not istable(t) then return Angle(0, 0, 0) end
    return Angle(tonumber(t.p) or 0, tonumber(t.y) or 0, tonumber(t.r) or 0)
end

local function SaveData()
    local payload = { spots = {}, dealer_spawns = {}, dealer_links = DBS.EliDealerLinks }

    for k, spot in pairs(DBS.BuyableSpots) do
        if spot and isvector(spot.Pos) and isangle(spot.Ang) then
            payload.spots[k] = { pos = EncodeVec(spot.Pos), ang = EncodeAng(spot.Ang) }
        end
    end

    for k, d in pairs(DBS.EliDealerSpawns) do
        if d and isvector(d.Pos) and isangle(d.Ang) then
            payload.dealer_spawns[k] = { pos = EncodeVec(d.Pos), ang = EncodeAng(d.Ang) }
        end
    end

    if not file.IsDir("dbs", "DATA") then file.CreateDir("dbs") end
    file.Write(SPOT_FILE, util.TableToJSON(payload, true))
end

local function LoadData()
    DBS.BuyableSpots = {}
    DBS.EliDealerSpawns = {}
    DBS.EliDealerLinks = {}
    if not file.Exists(SPOT_FILE, "DATA") then return end

    local parsed = util.JSONToTable(file.Read(SPOT_FILE, "DATA") or "")
    if not istable(parsed) then return end

    for k, spot in pairs(parsed.spots or parsed) do
        if istable(spot) and spot.pos then
            local pos = DecodeVec(spot.pos)
            if pos then DBS.BuyableSpots[k] = { Pos = pos, Ang = DecodeAng(spot.ang) } end
        end
    end

    for k, d in pairs(parsed.dealer_spawns or {}) do
        local pos = DecodeVec(d.pos)
        if pos then DBS.EliDealerSpawns[k] = { Pos = pos, Ang = DecodeAng(d.ang) } end
    end

    DBS.EliDealerLinks = istable(parsed.dealer_links) and parsed.dealer_links or {}
end

function DBS.Eli.SetBuyableSpot(teamID, class, pos, ang, dealerID)
    teamID = tonumber(teamID)
    dealerID = math.max(1, math.floor(tonumber(dealerID) or 1))
    if not teamID or not isstring(class) or not isvector(pos) then return false end
    DBS.BuyableSpots[SpotKey(teamID, dealerID, class)] = { Pos = pos, Ang = isangle(ang) and ang or Angle(0, 0, 0) }
    SaveData()
    return true
end

function DBS.Eli.GetBuyableSpot(teamID, class, dealerID)
    dealerID = math.max(1, math.floor(tonumber(dealerID) or 1))
    return DBS.BuyableSpots[SpotKey(teamID, dealerID, class)]
end

function DBS.Eli.SetDealerSpawn(teamID, dealerID, pos, ang)
    teamID = tonumber(teamID)
    dealerID = math.max(1, math.floor(tonumber(dealerID) or 1))
    if not teamID or not isvector(pos) then return false end
    DBS.EliDealerSpawns[DealerKey(teamID, dealerID)] = { Pos = pos, Ang = isangle(ang) and ang or Angle(0, 0, 0) }
    SaveData()
    return true
end

function DBS.Eli.ToggleDealerDoorLink(teamID, dealerID, doorID)
    if not doorID or doorID == "" then return false end
    teamID = tonumber(teamID)
    dealerID = math.max(1, math.floor(tonumber(dealerID) or 1))
    if not teamID then return false end

    local k = DealerKey(teamID, dealerID)
    DBS.EliDealerLinks[k] = DBS.EliDealerLinks[k] or {}

    local idx
    for i, v in ipairs(DBS.EliDealerLinks[k]) do
        if v == doorID then idx = i break end
    end

    if idx then table.remove(DBS.EliDealerLinks[k], idx) else table.insert(DBS.EliDealerLinks[k], doorID) end
    SaveData()
    return not idx
end

local function ShouldDealerBeActive(teamID, dealerID)
    local links = DBS.EliDealerLinks[DealerKey(teamID, dealerID)] or {}
    if #links == 0 then return false end
    for _, id in ipairs(links) do
        for _, door in ipairs(ents.GetAll()) do
            if DBS.Doors and DBS.Doors.IsDoor and DBS.Doors.IsDoor(door) and DBS.Doors.GetDoorID and DBS.Doors.GetDoorID(door) == id then
                if DBS.Doors.GetOwnerTeam(door) == teamID then return true end
            end
        end
    end
    return false
end

local function FindLinkedDealer(teamID, dealerID)
    for _, ent in ipairs(ents.FindByClass("dbs_npc_eli")) do
        if ent:GetNWBool("DBS_LinkedDealer", false) and ent:GetDealerTeam() == teamID and ent:GetDealerID() == dealerID then
            return ent
        end
    end
end

function DBS.Eli.RefreshDoorLinkedDealers()
    for key, spawn in pairs(DBS.EliDealerSpawns) do
        local teamID, dealerID = key:match("^(%d+):(%d+)$")
        teamID = tonumber(teamID)
        dealerID = tonumber(dealerID)
        if not teamID or not dealerID then continue end

        local active = ShouldDealerBeActive(teamID, dealerID)
        local existing = FindLinkedDealer(teamID, dealerID)

        if active and not IsValid(existing) then
            local ent = ents.Create("dbs_npc_eli")
            if IsValid(ent) then
                ent:SetPos(spawn.Pos)
                ent:SetAngles(spawn.Ang or Angle(0, 0, 0))
                ent:SetDealerTeam(teamID)
                ent:SetDealerID(dealerID)
                ent:SetNWBool("DBS_LinkedDealer", true)
                ent:Spawn()
            end
        elseif (not active) and IsValid(existing) then
            existing:Remove()
        end
    end
end

local function SpawnUtilityForPlayer(ply, class, fallbackPos, dealerID)
    local spot = DBS.Eli.GetBuyableSpot(ply:Team(), class, dealerID)
    local ent = ents.Create(class)
    if not IsValid(ent) then return nil end

    if spot and isvector(spot.Pos) then
        ent:SetPos(spot.Pos)
        ent:SetAngles(spot.Ang or Angle(0, 0, 0))
    else
        ent:SetPos(fallbackPos)
    end

    ent:Spawn()
    if spot and isvector(spot.Pos) then
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) phys:Sleep() end
    end
    return ent
end

local function CountOwnedByClass(ply, class, ownerNW)
    local sid = IsValid(ply) and ply:SteamID64() or ""
    local total = 0
    for _, ent in ipairs(ents.FindByClass(class)) do
        if ent:GetNWString(ownerNW, "") == sid then total = total + 1 end
    end
    return total
end

local function CountOwnedPrinters(ply) return CountOwnedByClass(ply, "dbs_money_printer", "DBS_PrinterOwnerSID") end
local function CountOwnedCokeProcessors(ply) return CountOwnedByClass(ply, "dbs_coke_printer", "DBS_CokeProcessorOwnerSID") end
local function CountOwnedDryingTables(ply) return CountOwnedByClass(ply, "dbs_coke_drying_table", "DBS_CokeDryTableOwnerSID") end
local function CountOwnedBrickPackers(ply) return CountOwnedByClass(ply, "dbs_coke_brick_packer", "DBS_CokeBrickPackerOwnerSID") end

function DBS.Eli.Open(ply, sourceDealer)
    local pCfg = DBS.Config.Printer or {}
    local cCfg = DBS.Config.CokePrinter or {}
    local dCfg = DBS.Config.CokeDryingTable or {}
    local bCfg = DBS.Config.CokeBrickPacker or {}

    local dealerID = math.max(1, ply:GetNWInt("DBS_EliDealerID", 1))
    if IsValid(sourceDealer) and sourceDealer.GetDealerID then
        dealerID = math.max(1, tonumber(sourceDealer:GetDealerID()) or 1)
    end
    ply:SetNWInt("DBS_EliDealerID", dealerID)

    net.Start("DBS_Eli_Open")
        net.WriteBool(DBS.Util.IsPolice(ply))
        net.WriteUInt(DBS.Player.GetCred(ply), 3)
        net.WriteInt(DBS.Player.GetMoney(ply), 32)
        net.WriteUInt(math.min(255, CountOwnedPrinters(ply)), 8)
        net.WriteUInt(math.min(255, math.max(1, pCfg.MaxPerPlayer or 5)), 8)
        net.WriteUInt(math.min(255, CountOwnedCokeProcessors(ply)), 8)
        net.WriteUInt(math.min(255, math.max(1, cCfg.MaxPerPlayer or 2)), 8)
        net.WriteUInt(math.min(255, CountOwnedDryingTables(ply)), 8)
        net.WriteUInt(math.min(255, math.max(1, dCfg.MaxPerPlayer or 2)), 8)
        net.WriteUInt(math.min(255, CountOwnedBrickPackers(ply)), 8)
        net.WriteUInt(math.min(255, math.max(1, bCfg.MaxPerPlayer or 2)), 8)
    net.Send(ply)
end

local function RefreshOpenMenu(ply)
    timer.Simple(0, function() if IsValid(ply) then DBS.Eli.Open(ply) end end)
end

net.Receive("DBS_Eli_Buy", function(_, ply)
    if not IsValid(ply) then return end

    local tier = net.ReadUInt(3)
    local class = net.ReadString()
    local isPolice = DBS.Util.IsPolice(ply)
    local shop = isPolice and DBS.Config.Shop.Police or DBS.Config.Shop.Gang
    local tierData = shop.Tiers[tier]
    if not tierData then return end

    local item
    for _, v in ipairs(tierData.Items) do
        if v.Class == class then item = v break end
    end
    if not item then return end
    if DBS.Player.GetCred(ply) < tier then DBS.Util.Notify(ply, "You don't have enough CRED.") return end
    if not ply:CanAfford(item.Price) then DBS.Util.Notify(ply, "You cannot afford this.") return end
    if not ply:CanCarryWeapon() then DBS.Util.Notify(ply, "Inventory full.") return end
    if not DBS.Inventory.NonGunWeapons[class] and not ply:CanCarryGun() then DBS.Util.Notify(ply, "You can only carry 2 guns.") return end

    ply:AddMoney(-item.Price)
    ply:Give(class)
    DBS.Util.Notify(ply, "Purchased " .. item.Name .. ".")
end)

net.Receive("DBS_Eli_Sell", function(_, ply)
    if not IsValid(ply) then return end
    local class = net.ReadString()
    if DBS.Inventory.IgnoreWeapons[class] or class == "weapon_dbs_lockpick" then return end
    local wep = ply:GetWeapon(class)
    if not IsValid(wep) or ply:GetActiveWeapon() == wep then return end
    local shop = DBS.Util.IsPolice(ply) and DBS.Config.Shop.Police or DBS.Config.Shop.Gang
    local price = shop.SellPrices[class]
    if not price then return end
    ply:StripWeapon(class)
    ply:AddMoney(price)
    RefreshOpenMenu(ply)
end)

local function BuyUtility(ply, class, cfg, countFn, ownerNW, label)
    local price = cfg.Price or 3000
    if not ply:CanAfford(price) then DBS.Util.Notify(ply, "Cannot afford " .. label .. ".") return end
    local maxPer = math.max(1, cfg.MaxPerPlayer or 2)
    local owned = countFn(ply)
    if owned >= maxPer then DBS.Util.Notify(ply, label .. " limit reached (" .. owned .. "/" .. maxPer .. ").") return end

    local tr = ply:GetEyeTrace()
    local pos = (tr and tr.HitPos or ply:GetPos() + ply:GetForward() * 70) + Vector(0, 0, 18)
    local dealerID = math.max(1, ply:GetNWInt("DBS_EliDealerID", 1))

    local ent = SpawnUtilityForPlayer(ply, class, pos, dealerID)
    if not IsValid(ent) then DBS.Util.Notify(ply, "Failed to spawn " .. label .. ".") return end

    ent:SetNWString(ownerNW, ply:SteamID64())
    ply:AddMoney(-price)
    DBS.Util.Notify(ply, "Bought " .. label .. " for $" .. string.Comma(price) .. ".")
    RefreshOpenMenu(ply)
end

net.Receive("DBS_Eli_BuyPrinter", function(_, ply) if IsValid(ply) then BuyUtility(ply, "dbs_money_printer", DBS.Config.Printer or {}, CountOwnedPrinters, "DBS_PrinterOwnerSID", "money printer") end end)
net.Receive("DBS_Eli_BuyCokePrinter", function(_, ply) if IsValid(ply) then BuyUtility(ply, "dbs_coke_printer", DBS.Config.CokePrinter or {}, CountOwnedCokeProcessors, "DBS_CokeProcessorOwnerSID", "coke processor") end end)
net.Receive("DBS_Eli_BuyDryingTable", function(_, ply) if IsValid(ply) then BuyUtility(ply, "dbs_coke_drying_table", DBS.Config.CokeDryingTable or {}, CountOwnedDryingTables, "DBS_CokeDryTableOwnerSID", "drying table") end end)
net.Receive("DBS_Eli_BuyBrickPacker", function(_, ply) if IsValid(ply) then BuyUtility(ply, "dbs_coke_brick_packer", DBS.Config.CokeBrickPacker or {}, CountOwnedBrickPackers, "DBS_CokeBrickPackerOwnerSID", "brick packer") end end)

hook.Add("InitPostEntity", "DBS.Eli.LoadBuyableSpots", function()
    LoadData()
    DBS.Eli.RefreshDoorLinkedDealers()
end)

hook.Add("DBS.Doors.OwnerChanged", "DBS.Eli.OwnerChangedRefresh", function()
    timer.Simple(0, function() DBS.Eli.RefreshDoorLinkedDealers() end)
end)
