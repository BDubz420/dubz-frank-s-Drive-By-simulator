hook.Add("PlayerCanPickupWeapon", "DBS.Inventory.LimitPickup", function(ply, wep)
    if not IsValid(ply) or not IsValid(wep) then return end

    local maxSlots = DBS.Inventory.GetMax(ply)
    local curSlots = DBS.Inventory.GetCount(ply)

    -- If they already have it, allow (ammo pickup behavior etc.)
    if ply:HasWeapon(wep:GetClass()) then return true end

    if curSlots >= maxSlots then
        net.Start(DBS.Net.Notify)
            net.WriteString("Inventory full.")
        net.Send(ply)
        return false
    end
end)
