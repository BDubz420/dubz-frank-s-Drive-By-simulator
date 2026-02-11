DBS = DBS or {}
DBS.Drop = DBS.Drop or {}

-- =========================
-- Weapon Drop Blacklist
-- =========================
DBS.Drop.Blacklist = {
    ["weapon_dbs_lockpick"] = true,
    ["weapon_dbs_hands"]    = true,
    ["weapon_fists"]        = true
}

-- =========================
-- Drop logic
-- =========================
local function DropActiveWeapon(ply)
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end

    local class = wep:GetClass()
    if DBS.Drop.Blacklist[class] then
        DBS.Util.Notify(ply, "You cannot drop this weapon.")
        return
    end

    ply:DropWeapon(wep)
end

-- =========================
-- Chat command
-- =========================
hook.Add("PlayerSay", "DBS.DropWeaponCommand", function(ply, text)
    if string.lower(text) == "/drop" then
        DropActiveWeapon(ply)
        return ""
    end
end)
