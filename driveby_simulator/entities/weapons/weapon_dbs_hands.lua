AddCSLuaFile()

SWEP.PrintName = "Hands"
SWEP.Author = "Dubz & Frank"
SWEP.Instructions = "Left click and hold to drag props."
SWEP.Category = "DriveBy Simulator"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.HoldType = "normal"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary = SWEP.Primary

local DRAG_DISTANCE = 170

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    local ent = tr.Entity

    if not IsValid(ent) or ent:IsPlayer() or ent:IsNPC() then return end

    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end

    self.DragEnt = ent
    self.DragPhys = phys
end

function SWEP:SecondaryAttack() return end
function SWEP:Reload() return end

function SWEP:Think()
    if not SERVER then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if not ply:KeyDown(IN_ATTACK) then
        self.DragEnt = nil
        self.DragPhys = nil
        return
    end

    if not IsValid(self.DragEnt) or not IsValid(self.DragPhys) then return end

    local targetPos = ply:GetShootPos() + ply:GetAimVector() * DRAG_DISTANCE
    local delta = targetPos - self.DragEnt:GetPos()

    self.DragPhys:Wake()
    self.DragPhys:SetVelocity(delta * 8)
end

if CLIENT then
    function SWEP:DrawHUD()
        local x, y = ScrW() * 0.5, ScrH() * 0.5
        surface.SetDrawColor(255, 255, 255, 220)
        surface.DrawLine(x - 6, y, x + 6, y)
        surface.DrawLine(x, y - 6, x, y + 6)
    end

    function SWEP:DrawWorldModel() end
    function SWEP:PreDrawViewModel() return true end
end
