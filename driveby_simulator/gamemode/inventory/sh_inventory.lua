DBS = DBS or {}
DBS.Inventory = DBS.Inventory or {}

local PLAYER = FindMetaTable("Player")

-- Weapons that NEVER count toward inventory
DBS.Inventory.IgnoreWeapons = {
    ["weapon_dbs_hands"] = true,
    ["weapon_fists"] = true -- safety fallback
}

-- Weapons that are NOT considered guns
DBS.Inventory.NonGunWeapons = {
    ["weapon_dbs_hands"] = true,
    ["weapon_fists"] = true,
    ["weapon_dbs_lockpick"] = true,
    ["weapon_dbs_pickpocket"] = true
}

-- ----------------------------
-- Core inventory counting
-- ----------------------------

function DBS.Inventory.GetCount(ply)
    if not IsValid(ply) then return 0 end

    local count = 0

    for _, wep in ipairs(ply:GetWeapons()) do
        if not IsValid(wep) then continue end

        local class = wep:GetClass()

        if DBS.Inventory.IgnoreWeapons[class] then continue end
        if wep.AdminOnly then continue end

        count = count + 1
    end

    return count
end

function DBS.Inventory.GetMax(ply)
    return DBS.Config.Core.InventorySlots
end

-- ----------------------------
-- Gun-specific logic
-- ----------------------------

function DBS.Inventory.GetGunCount(ply)
    if not IsValid(ply) then return 0 end

    local count = 0

    for _, wep in ipairs(ply:GetWeapons()) do
        if not IsValid(wep) then continue end

        local class = wep:GetClass()

        if DBS.Inventory.NonGunWeapons[class] then continue end
        if wep.AdminOnly then continue end

        count = count + 1
    end

    return count
end

-- Max guns allowed (hard design rule)
function DBS.Inventory.GetGunMax()
    return 2
end

-- ----------------------------
-- Player meta helpers (USED BY SHOP)
-- ----------------------------

function PLAYER:CanCarryWeapon()
    return DBS.Inventory.GetCount(self) < DBS.Inventory.GetMax(self)
end

function PLAYER:CanCarryGun()
    return DBS.Inventory.GetGunCount(self) < DBS.Inventory.GetGunMax()
end
