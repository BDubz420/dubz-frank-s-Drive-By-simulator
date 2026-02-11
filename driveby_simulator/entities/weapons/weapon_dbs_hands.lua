AddCSLuaFile()

if SERVER then
    util.AddNetworkString("DBS.HandsAdjustDistance")
end

SWEP.PrintName = "Hands"
SWEP.Author = "Dubz & Frank"
SWEP.Instructions = "Left click and hold to drag props. Scroll while dragging to change distance."
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

local DRAG_DISTANCE_DEFAULT = 155
local DRAG_DISTANCE_MIN = 70
local DRAG_DISTANCE_MAX = 230
local DRAG_DISTANCE_STEP = 12

function SWEP:Initialize()
    self:SetHoldType("normal")
    self.DragDistance = DRAG_DISTANCE_DEFAULT
end

function SWEP:IsDragging()
    return IsValid(self.DragEnt) and IsValid(self.DragPhys)
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

    self.DragDistance = math.Clamp(tr.HitPos:Distance(ply:GetShootPos()), DRAG_DISTANCE_MIN, DRAG_DISTANCE_MAX)
    self.DragEnt = ent
    self.DragPhys = phys
    ply:SetNWBool("DBS_IsDraggingProp", true)
end

function SWEP:SecondaryAttack() return end
function SWEP:Reload() return end

function SWEP:Holster()
    if SERVER and self:IsDragging() then
        return false
    end
    return true
end

function SWEP:OnRemove()
    if SERVER then
        local ply = self:GetOwner()
        if IsValid(ply) then
            ply:SetNWBool("DBS_IsDraggingProp", false)
        end
    end
end

if SERVER then
    net.Receive("DBS.HandsAdjustDistance", function(_, ply)
        local wep = IsValid(ply) and ply:GetActiveWeapon() or nil
        if not IsValid(wep) or wep:GetClass() ~= "weapon_dbs_hands" then return end
        if not wep:IsDragging() then return end

        local delta = net.ReadFloat()
        wep.DragDistance = math.Clamp((wep.DragDistance or DRAG_DISTANCE_DEFAULT) + delta, DRAG_DISTANCE_MIN, DRAG_DISTANCE_MAX)
    end)
end

function SWEP:Think()
    if not SERVER then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if not ply:KeyDown(IN_ATTACK) then
        self.DragEnt = nil
        self.DragPhys = nil
        ply:SetNWBool("DBS_IsDraggingProp", false)
        return
    end

    if not self:IsDragging() then return end

    if ply:KeyPressed(IN_INVNEXT) then
        self.DragDistance = math.Clamp((self.DragDistance or DRAG_DISTANCE_DEFAULT) + DRAG_DISTANCE_STEP, DRAG_DISTANCE_MIN, DRAG_DISTANCE_MAX)
    elseif ply:KeyPressed(IN_INVPREV) then
        self.DragDistance = math.Clamp((self.DragDistance or DRAG_DISTANCE_DEFAULT) - DRAG_DISTANCE_STEP, DRAG_DISTANCE_MIN, DRAG_DISTANCE_MAX)
    end

    local dragDistance = self.DragDistance or DRAG_DISTANCE_DEFAULT
    local targetPos = ply:GetShootPos() + ply:GetAimVector() * dragDistance
    local delta = targetPos - self.DragEnt:GetPos()

    self.DragPhys:Wake()
    self.DragPhys:SetVelocity(delta * 8)
end

if CLIENT then
    hook.Add("PlayerBindPress", "DBS.HandsScrollDistance", function(ply, bind, pressed)
        if not pressed or not IsValid(ply) then return end

        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_dbs_hands" then return end
        if not ply:GetNWBool("DBS_IsDraggingProp", false) then return end

        bind = string.lower(bind or "")
        local delta
        if string.find(bind, "invnext", 1, true) then
            delta = DRAG_DISTANCE_STEP
        elseif string.find(bind, "invprev", 1, true) then
            delta = -DRAG_DISTANCE_STEP
        end

        if not delta then return end

        net.Start("DBS.HandsAdjustDistance")
        net.WriteFloat(delta)
        net.SendToServer()
        return true
    end)

    function SWEP:DrawHUD()
        local x, y = ScrW() * 0.5, ScrH() * 0.5
        surface.SetDrawColor(255, 255, 255, 220)
        surface.DrawLine(x - 6, y, x + 6, y)
        surface.DrawLine(x, y - 6, x, y + 6)

        if LocalPlayer():GetNWBool("DBS_IsDraggingProp", false) then
            draw.SimpleText("Scroll: adjust hold distance", "DermaDefault", x, y + 16, Color(220, 220, 220), TEXT_ALIGN_CENTER)
        end
    end

    function SWEP:DrawWorldModel() end
    function SWEP:PreDrawViewModel() return true end
end
