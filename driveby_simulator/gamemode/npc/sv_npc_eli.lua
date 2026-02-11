DBS = DBS or {}
DBS.Eli = DBS.Eli or {}
DBS.BuyableSpots = DBS.BuyableSpots or {}

local function SpotKey(teamID, class)
    return tostring(teamID) .. ":" .. tostring(class)
end

function DBS.Eli.SetBuyableSpot(teamID, class, pos, ang)
    if not isnumber(teamID) or not isstring(class) then return end
    DBS.BuyableSpots[SpotKey(teamID, class)] = { Pos = pos, Ang = ang }
end

function DBS.Eli.GetBuyableSpot(teamID, class)
    return DBS.BuyableSpots[SpotKey(teamID, class)]
end

local function SpawnUtilityForPlayer(ply, class, fallbackPos)
    local spot = DBS.Eli.GetBuyableSpot(ply:Team(), class)
    local ent = ents.Create(class)
    if not IsValid(ent) then return nil end

    if spot and isvector(spot.Pos) then
        ent:SetPos(spot.Pos)
        ent:SetAngles(spot.Ang or Angle(0,0,0))
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

util.AddNetworkString("DBS_Eli_Open")
util.AddNetworkString("DBS_Eli_Buy")
util.AddNetworkString("DBS_Eli_Sell")
util.AddNetworkString("DBS_Eli_BuyPrinter")
util.AddNetworkString("DBS_Eli_BuyCokePrinter")

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
    if not IsValid(ply) then return 0 end

    return CountOwnedByClass(ply, "dbs_money_printer", "DBS_PrinterOwnerSID")
end

local function CountOwnedCokePrinters(ply)
    return CountOwnedByClass(ply, "dbs_coke_printer", "DBS_CokePrinterOwnerSID")
end

function DBS.Eli.Open(ply)
    local shop = DBS.Util.IsPolice(ply)
        and DBS.Config.Shop.Police
        or DBS.Config.Shop.Gang

    local pCfg = DBS.Config.Printer or {}
    local printerMax = math.max(1, pCfg.MaxPerPlayer or 5)
    local cCfg = DBS.Config.CokePrinter or {}
    local cokeMax = math.max(1, cCfg.MaxPerPlayer or 2)

    net.Start("DBS_Eli_Open")
        net.WriteBool(DBS.Util.IsPolice(ply))
        net.WriteUInt(DBS.Player.GetCred(ply), 3)
        net.WriteInt(DBS.Player.GetMoney(ply), 32)
        net.WriteUInt(math.min(255, CountOwnedPrinters(ply)), 8)
        net.WriteUInt(math.min(255, printerMax), 8)
        net.WriteUInt(math.min(255, CountOwnedCokePrinters(ply)), 8)
        net.WriteUInt(math.min(255, cokeMax), 8)
    net.Send(ply)
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

    -- Tier check
    if DBS.Player.GetCred(ply) < tier then
        DBS.Util.Notify(ply, "You don't have enough CRED.")
        return
    end

    -- Money check
    if not ply:CanAfford(item.Price) then
        DBS.Util.Notify(ply, "You cannot afford this.")
        return
    end

    -- Inventory slot check
    if not ply:CanCarryWeapon() then
        DBS.Util.Notify(ply, "Inventory full.")
        return
    end

    -- Gun cap check
    if not DBS.Inventory.NonGunWeapons[class] and not ply:CanCarryGun() then
        DBS.Util.Notify(ply, "You can only carry 2 guns.")
        return
    end

    -- Purchase success
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

    -- Disallowed items
    if DBS.Inventory.IgnoreWeapons[class] or class == "weapon_dbs_lockpick" then
        DBS.Util.Notify(ply, "You cannot sell this item.")
        return
    end

    -- Must actually own weapon
    local wep = ply:GetWeapon(class)
    if not IsValid(wep) then
        DBS.Util.Notify(ply, "You do not have this weapon.")
        return
    end

    -- Cannot sell active weapon
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

    -- Success
    ply:StripWeapon(class)
    ply:AddMoney(price)

    DBS.Util.Notify(ply, "Sold for $" .. price .. ".")
end)


net.Receive("DBS_Eli_BuyPrinter", function(_, ply)
    if not IsValid(ply) then return end

    local cfg = DBS.Config.Printer or {}
    local price = cfg.Price or 3000

    local econCooldown = DBS.Config.Economy and DBS.Config.Economy.TransactionCooldown or 0.25
    if not ply:CanRunEconomyAction(econCooldown) then return end

    if not ply:CanAfford(price) then
        DBS.Util.Notify(ply, "Cannot afford money printer.")
        return
    end

    local maxPerPlayer = math.max(1, cfg.MaxPerPlayer or 5)
    local ownedCount = CountOwnedPrinters(ply)
    if ownedCount >= maxPerPlayer then
        DBS.Util.Notify(ply, "Printer limit reached (" .. ownedCount .. "/" .. maxPerPlayer .. ").")
        return
    end

    local tr = ply:GetEyeTrace()
    local pos = (tr and tr.HitPos or (ply:GetPos() + ply:GetForward() * 70)) + Vector(0,0,16)

    local printer = SpawnUtilityForPlayer(ply, "dbs_money_printer", pos)
    if not IsValid(printer) then
        DBS.Util.Notify(ply, "Failed to spawn printer.")
        return
    end
    printer:SetNWString("DBS_PrinterOwnerSID", ply:SteamID64())

    ply:AddMoney(-price)
    DBS.Util.Notify(ply, "Bought money printer for $" .. string.Comma(price) .. ".")
end)


net.Receive("DBS_Eli_BuyCokePrinter", function(_, ply)
    if not IsValid(ply) then return end

    local cfg = DBS.Config.CokePrinter or {}
    local price = cfg.Price or 9000

    local econCooldown = DBS.Config.Economy and DBS.Config.Economy.TransactionCooldown or 0.25
    if not ply:CanRunEconomyAction(econCooldown) then return end

    if not ply:CanAfford(price) then
        DBS.Util.Notify(ply, "Cannot afford coke printer.")
        return
    end

    local maxPerPlayer = math.max(1, cfg.MaxPerPlayer or 2)
    local ownedCount = CountOwnedCokePrinters(ply)
    if ownedCount >= maxPerPlayer then
        DBS.Util.Notify(ply, "Coke printer limit reached (" .. ownedCount .. "/" .. maxPerPlayer .. ").")
        return
    end

    local tr = ply:GetEyeTrace()
    local pos = (tr and tr.HitPos or (ply:GetPos() + ply:GetForward() * 70)) + Vector(0,0,18)

    local printer = SpawnUtilityForPlayer(ply, "dbs_coke_printer", pos)
    if not IsValid(printer) then
        DBS.Util.Notify(ply, "Failed to spawn coke printer.")
        return
    end
    printer:SetNWString("DBS_CokePrinterOwnerSID", ply:SteamID64())

    ply:AddMoney(-price)
    DBS.Util.Notify(ply, "Bought coke printer for $" .. string.Comma(price) .. ".")
end)
