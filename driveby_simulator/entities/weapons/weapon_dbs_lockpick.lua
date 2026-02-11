
if CLIENT then
    hook.Add("HUDPaint", "DBS.Lockpick.Progress", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local finish = ply:GetNWFloat("DBS_LockpickEnd", 0)
        if finish <= CurTime() then return end

        local start = ply:GetNWFloat("DBS_LockpickStart", 0)
        local frac = math.Clamp((CurTime() - start) / math.max(0.1, finish - start), 0, 1)

        local w, h = 360, 58
        local x = (ScrW() - w) * 0.5
        local y = ScrH() * 0.78

        draw.RoundedBox(10, x, y, w, h, Color(14, 14, 18, 225))
        draw.SimpleText("Lockpicking...", "DBS_UI_Body", x + 14, y + 16, color_white, TEXT_ALIGN_LEFT)
        draw.RoundedBox(6, x + 14, y + 34, w - 28, 14, Color(40, 40, 40, 180))
        draw.RoundedBox(6, x + 16, y + 36, (w - 32) * frac, 10, Color(80, 180, 120, 230))
    end)
end

AddCSLuaFile()

SWEP.PrintName = "Lockpick"
SWEP.Author = "Dubz & Frank"
SWEP.Instructions = "Left click to lockpick doors/vehicles."
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

local PICK_DISTANCE = 130

local function IsPickableVehicle(ent)
    if not IsValid(ent) then return false end
    return ent:IsVehicle() or string.find(ent:GetClass(), "prop_vehicle", 1, true)
end

local function IsPickableDoor(ent)
    return DBS.Doors and DBS.Doors.IsDoor and DBS.Doors.IsDoor(ent)
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local ply = self:GetOwner()
    if not IsValid(ply) or ply:InVehicle() then return end

    self:SetNextPrimaryFire(CurTime() + 0.5)

    local tr = ply:GetEyeTrace()
    if not tr.Hit or not IsValid(tr.Entity) then return end
    if ply:GetPos():DistToSqr(tr.HitPos) > (PICK_DISTANCE * PICK_DISTANCE) then return end

    local ent = tr.Entity
    local pickVehicle = IsPickableVehicle(ent)
    local pickDoor = IsPickableDoor(ent)

    if not pickVehicle and not pickDoor then
        DBS.Util.Notify(ply, "You can only lockpick doors and vehicles.")
        return
    end

    if ply:GetNWBool("DBS_IsLockpicking", false) then return end
    ply:SetNWBool("DBS_IsLockpicking", true)

    local lockTime = DBS.Config.Cars.LockpickTime or 3
    ply:SetNWFloat("DBS_LockpickStart", CurTime())
    ply:SetNWFloat("DBS_LockpickEnd", CurTime() + lockTime)
    local startPos = ply:GetPos()

    if DBS.Config.Cars.LoudLockpick then
        ent:EmitSound("ambient/materials/metal_stress1.wav", 100, 100)
        ent:EmitSound("ambient/materials/metal_stress2.wav", 100, 100)
    end

    DBS.Util.Notify(ply, "Lockpicking...")

    timer.Simple(lockTime, function()
        if not IsValid(ply) then return end

        ply:SetNWBool("DBS_IsLockpicking", false)
        ply:SetNWFloat("DBS_LockpickEnd", 0)

        if not ply:Alive() then return end
        if ply:InVehicle() then return end
        if ply:GetPos():DistToSqr(startPos) > (120 * 120) then return end
        if not IsValid(ent) then return end

        if pickVehicle then
            if DBS.Vehicles and DBS.Vehicles.HandleConversion then
                DBS.Vehicles.HandleConversion(ply, ent)
            end

            if IsValid(ent:GetDriver()) and ent:GetDriver() ~= ply then
                DBS.Util.Notify(ply, "Someone is driving this right now.")
                return
            end

            ply:EnterVehicle(ent)
            DBS.Util.Notify(ply, "Vehicle lockpicked.")
            return
        end

        if pickDoor then
            ent:SetNWFloat("DBS_DoorBreachUntil", CurTime() + 8)
            ply:SetNWFloat("DBS_DoorAccessUntil", CurTime() + 8)
            ent:Fire("Unlock", "", 0)
            ent:Fire("Open", "", 0.05)
            DBS.Util.Notify(ply, "Door lockpicked. You have a short access window.")
            return
        end
    end)
end
