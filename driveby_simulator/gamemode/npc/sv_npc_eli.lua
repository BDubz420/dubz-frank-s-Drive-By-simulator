DBS = DBS or {}
DBS.Eli = DBS.Eli or {}

util.AddNetworkString("DBS_Eli_Open")
util.AddNetworkString("DBS_Eli_Buy")
util.AddNetworkString("DBS_Eli_Sell")
util.AddNetworkString("DBS_Eli_BuyPrinter")

function DBS.Eli.Open(ply)
    local shop = DBS.Util.IsPolice(ply)
        and DBS.Config.Shop.Police
        or DBS.Config.Shop.Gang

    net.Start("DBS_Eli_Open")
        net.WriteBool(DBS.Util.IsPolice(ply))
        net.WriteUInt(DBS.Player.GetCred(ply), 3)
        net.WriteInt(DBS.Player.GetMoney(ply), 32)
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

    local tr = ply:GetEyeTrace()
    local pos = (tr and tr.HitPos or (ply:GetPos() + ply:GetForward() * 70)) + Vector(0,0,16)

    local printer = ents.Create("dbs_money_printer")
    if not IsValid(printer) then
        DBS.Util.Notify(ply, "Failed to spawn printer.")
        return
    end

    printer:SetPos(pos)
    printer:Spawn()

    ply:AddMoney(-price)
    DBS.Util.Notify(ply, "Bought money printer for $" .. string.Comma(price) .. ".")
end)
