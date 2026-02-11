AddCSLuaFile()

SWEP.PrintName = "Pickpocket"
SWEP.Author = "Dubz & Frank"
SWEP.Instructions = "Steal from NPCs/players at close range."
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

local PICK_RANGE = 90

local function GetStealAmount(target)
    if target:IsPlayer() then
        local total = target:GetMoney()
        if total <= 0 then return 0 end

        return math.Clamp(math.floor(total * 0.2), 40, 450)
    end

    return math.random(30, 160)
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    self:SetNextPrimaryFire(CurTime() + 1.2)

    local tr = ply:GetEyeTrace()
    local target = tr.Entity

    if not IsValid(target) then
        DBS.Util.Notify(ply, "No target.")
        return
    end

    if ply:GetPos():DistToSqr(target:GetPos()) > (PICK_RANGE * PICK_RANGE) then
        DBS.Util.Notify(ply, "Get closer.")
        return
    end

    local canPickpocket = target:IsPlayer() or target:IsNPC()
    if not canPickpocket then
        DBS.Util.Notify(ply, "You can only pickpocket people.")
        return
    end

    local successChance = target:IsPlayer() and 0.45 or 0.7
    local success = math.Rand(0, 1) <= successChance

    if not success then
        DBS.Util.Notify(ply, "You got spotted!")

        if target:IsPlayer() then
            DBS.Util.Notify(target, ply:Nick() .. " tried to pickpocket you!")
        end

        target:EmitSound("vo/npc/male01/gethellout.wav", 75, 105)
        return
    end

    local amount = GetStealAmount(target)
    if amount <= 0 then
        DBS.Util.Notify(ply, "Target has nothing worth taking.")
        return
    end

    if target:IsPlayer() then
        amount = math.min(amount, target:GetMoney())
        target:AddMoney(-amount)
    end

    ply:AddMoney(amount)

    DBS.Util.Notify(ply, "You lifted $" .. string.Comma(amount) .. ".")

    if target:IsPlayer() then
        DBS.Util.Notify(target, "You were pickpocketed for $" .. string.Comma(amount) .. ".")
    end
end
