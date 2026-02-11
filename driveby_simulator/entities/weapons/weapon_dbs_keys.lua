AddCSLuaFile()

SWEP.PrintName = "Property Keys"
SWEP.Author = "Dubz & Frank"
SWEP.Instructions = "Left click: Lock door | Right click: Unlock door"
SWEP.Category = "DriveBy Simulator"
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary = SWEP.Primary

local function TryDoorAction(ply, action)
    if not IsValid(ply) then return end

    local tr = ply:GetEyeTrace()
    local door = tr and tr.Entity
    if not (DBS and DBS.Doors and DBS.Doors.IsDoor and DBS.Doors.IsDoor(door)) then return end

    if ply:GetPos():DistToSqr(door:GetPos()) > (160 * 160) then return end

    local ownerTeam = DBS.Doors.GetOwnerTeam(door)
    if ownerTeam == 0 or ownerTeam ~= ply:Team() then
        if DBS and DBS.Util and DBS.Util.Notify then
            DBS.Util.Notify(ply, "You don't own this property.")
        end
        return
    end

    if action == "lock" then
        door:Fire("Lock", "", 0)
        door:SetSaveValue("m_bLocked", true)
        if DBS and DBS.Util and DBS.Util.Notify then DBS.Util.Notify(ply, "Door locked.") end
    else
        door:Fire("Unlock", "", 0)
        door:SetSaveValue("m_bLocked", false)
        if DBS and DBS.Util and DBS.Util.Notify then DBS.Util.Notify(ply, "Door unlocked.") end
    end
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    TryDoorAction(self:GetOwner(), "lock")
    self:SetNextPrimaryFire(CurTime() + 0.35)
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    TryDoorAction(self:GetOwner(), "unlock")
    self:SetNextSecondaryFire(CurTime() + 0.35)
end

function SWEP:Reload() return end

if CLIENT then
    function SWEP:DrawHUD()
        local x, y = ScrW() * 0.5, ScrH() * 0.5
        surface.SetDrawColor(255, 235, 120, 220)
        surface.DrawLine(x - 6, y, x + 6, y)
        surface.DrawLine(x, y - 6, x, y + 6)
        draw.SimpleText("LMB: Lock  RMB: Unlock", "DermaDefault", x, y + 16, Color(235, 225, 170), TEXT_ALIGN_CENTER)
    end

    function SWEP:DrawWorldModel() end
    function SWEP:PreDrawViewModel() return true end
end
