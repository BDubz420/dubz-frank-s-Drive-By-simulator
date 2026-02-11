DBS = DBS or {}
DBS.Eli = DBS.Eli or {}
DBS.BuyableSpots = DBS.BuyableSpots or {}

util.AddNetworkString("DBS_Eli_Open")
util.AddNetworkString("DBS_Eli_Buy")
util.AddNetworkString("DBS_Eli_Sell")
util.AddNetworkString("DBS_Eli_BuyPrinter")
util.AddNetworkString("DBS_Eli_BuyCokePrinter")
util.AddNetworkString("DBS_Eli_BuyDryingTable")
util.AddNetworkString("DBS_Eli_BuyBrickPacker")

local SPOT_FILE = "dbs/buyable_spots_" .. game.GetMap() .. ".json"

local function SpotKey(teamID, dealerID, class)
    return tostring(teamID) .. ":" .. tostring(dealerID) .. ":" .. tostring(class)
end

local function SerializeSpots()
    local out = {}
    for k, spot in pairs(DBS.BuyableSpots) do
        if istable(spot) and isvector(spot.Pos) then
            out[k] = {
                pos = { x = spot.Pos.x, y = spot.Pos.y, z = spot.Pos.z },
                ang = isangle(spot.Ang) and { p = spot.Ang.p, y = spot.Ang.y, r = spot.Ang.r } or { p = 0, y = 0, r = 0 }
            }
        end
    end
    return out
end

local function SaveSpots()
    if not file.IsDir("dbs", "DATA") then file.CreateDir("dbs") end
    file.Write(SPOT_FILE, util.TableToJSON(SerializeSpots(), true))
end

local function LoadSpots()
    DBS.BuyableSpots = {}
    if not file.Exists(SPOT_FILE, "DATA") then return end

    local parsed = util.JSONToTable(file.Read(SPOT_FILE, "DATA") or "")
    if not istable(parsed) then return end

    for k, spot in pairs(parsed) do
        if istable(spot) and istable(spot.pos) then
            local x, y, z = tonumber(spot.pos.x), tonumber(spot.pos.y), tonumber(spot.pos.z)
            if x and y and z then
                DBS.BuyableSpots[k] = {
                    Pos = Vector(x, y, z),
                    Ang = Angle(tonumber(spot.ang and spot.ang.p) or 0, tonumber(spot.ang and spot.ang.y) or 0, tonumber(spot.ang and spot.ang.r) or 0)
                }
            end
        end
    end
end

function DBS.Eli.SetBuyableSpot(teamID, class, pos, ang, dealerID)
    if not isnumber(teamID) or not isstring(class) or not isvector(pos) then return false end

    dealerID = math.max(1, math.floor(tonumber(dealerID) or 1))
    DBS.BuyableSpots[SpotKey(teamID, dealerID, class)] = {
        Pos = pos,
        Ang = isangle(ang) and ang or Angle(0, 0, 0)
    }

    SaveSpots()
    return true
end

function DBS.Eli.GetBuyableSpot(teamID, class, dealerID)
    dealerID = math.max(1, math.floor(tonumber(dealerID) or 1))
    return DBS.BuyableSpots[SpotKey(teamID, dealerID, class)]
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
        ent:SetMoveType(MOVETYPE_NONE)
        ent:SetSolid(SOLID_VPHYSICS)
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Sleep()
        end
    end

    return ent
end

local function CountOwnedByClass(ply, class, ownerNW)
    if not IsValid(ply) then return 0 end

    local sid = ply:SteamID64()
    local total = 0
    for _, ent in ipairs(ents.FindByClass(class)) do
        if not IsValid(ent) then continue end

        if ent:GetNWString(ownerNW, "") == sid then
            total = total + 1
        end
    end

    return total
end

local function CountOwnedPrinters(ply)
    return CountOwnedByClass(ply, "dbs_money_printer", "DBS_PrinterOwnerSID")
end

local function CountOwnedCokeProcessors(ply)
    return CountOwnedByClass(ply, "dbs_coke_printer", "DBS_CokeProcessorOwnerSID")
end

local function CountOwnedDryingTables(ply)
    return CountOwnedByClass(ply, "dbs_coke_drying_table", "DBS_CokeDryTableOwnerSID")
end

local function CountOwnedBrickPackers(ply)
    return CountOwnedByClass(ply, "dbs_coke_brick_packer", "DBS_CokeBrickPackerOwnerSID")
end

function DBS.Eli.Open(ply, sourceDealer)
    local shop = DBS.Util.IsPolice(ply)
        and DBS.Config.Shop.Police
        or DBS.Config.Shop.Gang

    local pCfg = DBS.Config.Printer or {}
    local printerMax = math.max(1, pCfg.MaxPerPlayer or 5)
    local cCfg = DBS.Config.CokePrinter or {}
    local cokeMax = math.max(1, cCfg.MaxPerPlayer or 2)
    local dCfg = DBS.Config.CokeDryingTable or {}
    local dryMax = math.max(1, dCfg.MaxPerPlayer or 2)
    local bCfg = DBS.Config.CokeBrickPacker or {}
    local packerMax = math.max(1, bCfg.MaxPerPlayer or 2)

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
        net.WriteUInt(math.min(255, printerMax), 8)
        net.WriteUInt(math.min(255, CountOwnedCokeProcessors(ply)), 8)
        net.WriteUInt(math.min(255, cokeMax), 8)
        net.WriteUInt(math.min(255, CountOwnedDryingTables(ply)), 8)
        net.WriteUInt(math.min(255, dryMax), 8)
        net.WriteUInt(math.min(255, CountOwnedBrickPackers(ply)), 8)
        net.WriteUInt(math.min(255, packerMax), 8)
    net.Send(ply)
end

local function RefreshOpenMenu(ply)
    timer.Simple(0, function()
        if IsValid(ply) then
            DBS.Eli.Open(ply)
        end
    end)
end

net.Receive("DBS_Eli_Buy", function(_, ply)
    if not IsValid(ply) then return end

    local tier = net.ReadUInt(3)
    local class = net.ReadString()

    local econCooldown = DBS.Config.Economy and DBS.Config.Economy.TransactionCooldown or 0.25
    if not ply:CanRunEconomyAction(econCooldown) then
        DBS.Util.Notify(ply, "Slow down. One deal at a time.")
        return
    end

    local isPolice = DBS.Util.IsPolice(ply)
    local shop = isPolice and DBS.Config.Shop.Police or DBS.Config.Shop.Gang
    local tierData = shop.Tiers[tier]
    if not tierData then return end

    local item
    for _, v in ipairs(tierData.Items) do
        if v.Class == class then
            item = v
            break
        end
    end
    if not item then return end

    if DBS.Player.GetCred(ply) < tier then
        DBS.Util.Notify(ply, "You don't have enough CRED.")
        return
    end

    if not ply:CanAfford(item.Price) then
        DBS.Util.Notify(ply, "You cannot afford this.")
        return
    end

    if not ply:CanCarryWeapon() then
        DBS.Util.Notify(ply, "Inventory full.")
        return
    end

    if not DBS.Inventory.NonGunWeapons[class] and not ply:CanCarryGun() then
        DBS.Util.Notify(ply, "You can only carry 2 guns.")
        return
    end

    ply:AddMoney(-item.Price)
    ply:Give(class)
    DBS.Util.Notify(ply, "Purchased " .. item.Name .. ".")
end)

net.Receive("DBS_Eli_Sell", function(_, ply)
    if not IsValid(ply) then return end

    local class = net.ReadString()
    if not class or class == "" then return end

    local econCooldown = DBS.Config.Economy and DBS.Config.Economy.TransactionCooldown or 0.25
    if not ply:CanRunEconomyAction(econCooldown) then
        DBS.Util.Notify(ply, "Slow down. One deal at a time.")
        return
    end

    if DBS.Inventory.IgnoreWeapons[class] or class == "weapon_dbs_lockpick" then
        DBS.Util.Notify(ply, "You cannot sell this item.")
        return
    end

    local wep = ply:GetWeapon(class)
    if not IsValid(wep) then
        DBS.Util.Notify(ply, "You do not have this weapon.")
        return
    end

    if ply:GetActiveWeapon() == wep then
        DBS.Util.Notify(ply, "Holster this weapon before selling.")
        return
    end

    local isPolice = DBS.Util.IsPolice(ply)
    local shop = isPolice and DBS.Config.Shop.Police or DBS.Config.Shop.Gang
    local price = shop.SellPrices[class]

    if not price then
        DBS.Util.Notify(ply, "This item cannot be sold.")
        return
    end

    ply:StripWeapon(class)
    ply:AddMoney(price)

    DBS.Util.Notify(ply, "Sold for $" .. price .. ".")
    RefreshOpenMenu(ply)
end)

local function BuyUtility(ply, class, cfg, countFn, ownerNW, failName)
    local price = cfg.Price or 3000

    local econCooldown = DBS.Config.Economy and DBS.Config.Economy.TransactionCooldown or 0.25
    if not ply:CanRunEconomyAction(econCooldown) then return end

    if not ply:CanAfford(price) then
        DBS.Util.Notify(ply, "Cannot afford " .. failName .. ".")
        return
    end

    local maxPerPlayer = math.max(1, cfg.MaxPerPlayer or 2)
    local ownedCount = countFn(ply)
    if ownedCount >= maxPerPlayer then
        DBS.Util.Notify(ply, failName .. " limit reached (" .. ownedCount .. "/" .. maxPerPlayer .. ").")
        return
    end

    local tr = ply:GetEyeTrace()
    local pos = (tr and tr.HitPos or (ply:GetPos() + ply:GetForward() * 70)) + Vector(0, 0, 18)
    local dealerID = math.max(1, ply:GetNWInt("DBS_EliDealerID", 1))

    local ent = SpawnUtilityForPlayer(ply, class, pos, dealerID)
    if not IsValid(ent) then
        DBS.Util.Notify(ply, "Failed to spawn " .. failName .. ".")
        return
    end

    ent:SetNWString(ownerNW, ply:SteamID64())
    ply:AddMoney(-price)
    DBS.Util.Notify(ply, "Bought " .. failName .. " for $" .. string.Comma(price) .. ".")
    RefreshOpenMenu(ply)
end

net.Receive("DBS_Eli_BuyPrinter", function(_, ply)
    if not IsValid(ply) then return end
    BuyUtility(ply, "dbs_money_printer", DBS.Config.Printer or {}, CountOwnedPrinters, "DBS_PrinterOwnerSID", "money printer")
end)

net.Receive("DBS_Eli_BuyCokePrinter", function(_, ply)
    if not IsValid(ply) then return end
    BuyUtility(ply, "dbs_coke_printer", DBS.Config.CokePrinter or {}, CountOwnedCokeProcessors, "DBS_CokeProcessorOwnerSID", "coke processor")
end)

net.Receive("DBS_Eli_BuyDryingTable", function(_, ply)
    if not IsValid(ply) then return end
    BuyUtility(ply, "dbs_coke_drying_table", DBS.Config.CokeDryingTable or {}, CountOwnedDryingTables, "DBS_CokeDryTableOwnerSID", "drying table")
end)

net.Receive("DBS_Eli_BuyBrickPacker", function(_, ply)
    if not IsValid(ply) then return end
    BuyUtility(ply, "dbs_coke_brick_packer", DBS.Config.CokeBrickPacker or {}, CountOwnedBrickPackers, "DBS_CokeBrickPackerOwnerSID", "brick packer")
end)

hook.Add("InitPostEntity", "DBS.Eli.LoadBuyableSpots", LoadSpots)
