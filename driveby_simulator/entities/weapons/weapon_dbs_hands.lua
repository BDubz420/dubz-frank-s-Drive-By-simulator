AddCSLuaFile()

SWEP.PrintName = "Hands"
SWEP.Author = "Dubz & Frank"
SWEP.Instructions = ""
SWEP.Category = "DriveBy Simulator"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.HoldType = "normal"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary = SWEP.Primary

function SWEP:Initialize()
    self:SetHoldType("normal")
end

-- Disable all attacks
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end
function SWEP:Reload() end

-- Prevent lag spam
function SWEP:Think() end

-- Hide viewmodel completely
if CLIENT then
    function SWEP:DrawHUD() end
    function SWEP:DrawWorldModel() end
    function SWEP:PreDrawViewModel() return true end
end
