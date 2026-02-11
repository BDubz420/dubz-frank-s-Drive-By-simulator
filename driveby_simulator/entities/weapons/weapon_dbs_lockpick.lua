AddCSLuaFile()

SWEP.PrintName = "Lockpick"
SWEP.Author = "Dubz & Frank"
SWEP.Instructions = "Left click to lockpick a vehicle."
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local PICK_DISTANCE = 120

function SWEP:PrimaryAttack()
    if not SERVER then return end
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    if ply:InVehicle() then return end

    self:SetNextPrimaryFire(CurTime() + 0.5)

    local tr = ply:GetEyeTrace()
    if not tr.Hit or not IsValid(tr.Entity) then return end
    if ply:GetPos():Distance(tr.HitPos) > PICK_DISTANCE then return end

    local ent = tr.Entity
    if not ent:IsVehicle() and not string.find(ent:GetClass(), "prop_vehicle", 1, true) then return end

    if ply:GetNWBool("DBS_IsLockpicking", false) then return end
    ply:SetNWBool("DBS_IsLockpicking", true)

    if DBS.Config.Cars.LoudLockpick then
        ent:EmitSound("ambient/materials/metal_stress1.wav", 100, 100)
        ent:EmitSound("ambient/materials/metal_stress2.wav", 100, 100)
    end

    local lockTime = DBS.Config.Cars.LockpickTime or 3
    local startPos = ply:GetPos()

    timer.Simple(lockTime, function()
        if not IsValid(ply) then return end
        ply:SetNWBool("DBS_IsLockpicking", false)

        -- cancel if moved too far / died
        if not ply:Alive() then return end
        if ply:GetPos():Distance(startPos) > 120 then return end
        if not IsValid(ent) then return end
        if ply:InVehicle() then return end

        -- Convert if enemy-owned
        if DBS.Vehicles and DBS.Vehicles.HandleConversion then
            DBS.Vehicles.HandleConversion(ply, ent)
        end

        ply:EnterVehicle(ent)
    end)
end
