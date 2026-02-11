DBS.Economy = DBS.Economy or {}

function DBS.Economy.DropMoney(ply)
    local amt = ply:GetMoney()
    if amt <= 0 then return end

    local ent = ents.Create("dbs_money_drop")
    if not IsValid(ent) then return end

    ent:SetPos(ply:GetPos() + Vector(0, 0, 20))
    ent:SetAmount(amt)
    ent:Spawn()
end

function DBS.Economy.DropWeapons(ply)
    for _, wep in ipairs(ply:GetWeapons()) do
        local class = wep:GetClass()
        if class == "weapon_fists" or class == "weapon_dbs_lockpick" then
            -- base kit stays “conceptually”, but you still respawn with it anyway
            -- we will keep these off the ground to avoid clutter
        else
            ply:DropWeapon(wep)
        end
    end
end

function DBS.Economy.DropAll(ply)
    DBS.Economy.DropMoney(ply)
    DBS.Economy.DropWeapons(ply)
end
