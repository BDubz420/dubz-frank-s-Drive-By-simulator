DBS = DBS or {}
DBS.Police = DBS.Police or {}

local function CanArrest(cop, target)
    if not IsValid(cop) or not cop:IsPlayer() then return false end
    if not IsValid(target) or not target:IsPlayer() then return false end
    if not target:Alive() then return false end
    if DBS.Util.IsPolice(target) then return false end

    local wep = cop:GetActiveWeapon()
    if not IsValid(wep) then return false end

    local req = DBS.Config.Police and DBS.Config.Police.ArrestWeaponClass or "weapon_stunstick"
    if wep:GetClass() ~= req then return false end

    local range = DBS.Config.Police and DBS.Config.Police.ArrestRange or 130
    if cop:GetPos():DistToSqr(target:GetPos()) > (range * range) then return false end

    return true
end

hook.Add("KeyPress", "DBS.Police.ArrestKey", function(ply, key)
    if key ~= IN_RELOAD then return end
    if not DBS.Util.IsPolice(ply) then return end

    local cooldown = DBS.Config.Police and DBS.Config.Police.ArrestCooldown or 1.5
    if not ply:CanRunEconomyAction(cooldown) then return end

    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then return end

    local target = tr.Entity
    if not CanArrest(ply, target) then return end

    target.DBS_SendToCourt = nil
    target.DBS_InCourt = nil
    target.DBS_JailTime = nil

    DBS.Util.Notify(ply, "Arrest made. Suspect forwarded to judge.")
    DBS.Util.Notify(target, "You have been arrested.")

    target:StripWeapons()
    DBS.Court.SendPlayer(target)
end)
