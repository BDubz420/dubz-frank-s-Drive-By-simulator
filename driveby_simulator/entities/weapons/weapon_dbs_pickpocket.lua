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

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local PICK_RANGE = 90
local BLOCKED_NPCS = {
    ["dbs_npc_eli"] = true,
    ["dbs_npc_jerome"] = true,
    ["dbs_npc_pickpocket_trainer"] = true,
    ["dbs_npc_judge"] = true,
    ["dbs_npc_lockpick_trainer"] = true
}

local function GetPickTimeForPlayer(ply)
    local lvl = math.max(1, ply:GetNWInt("DBS_PickpocketSkillLevel", 1))
    return math.Clamp(3.8 - (lvl - 1) * 0.5, 1.55, 3.8)
end

local function GetPickSuccessChance(level, isPlayerTarget)
    local base = isPlayerTarget and 0.35 or 0.62
    return math.Clamp(base + (level - 1) * 0.11, 0.2, 0.9)
end

local function GetStealScale(level)
    return 0.18 + (level - 1) * 0.06
end

function SWEP:SecondaryAttack()
    return
end

local function IsBlockedTarget(ent)
    if not IsValid(ent) then return false end

    local class = ent:GetClass()
    if BLOCKED_NPCS[class] then return true end
    if string.StartWith(class, "dbs_npc_") then return true end
    if class == "dbs_drug_dropbox" or class == "dbs_territory_pole" then return true end

    return false
end

local function GetStealAmount(target, level)
    if target:IsPlayer() then
        local total = target:GetMoney()
        if total <= 0 then return 0 end
        local pct = GetStealScale(level)
        return math.Clamp(math.floor(total * pct), 35 + level * 10, 300 + level * 120)
    end

    return math.random(20 + level * 10, 90 + level * 35)
end

if CLIENT then
    hook.Add("HUDPaint", "DBS.Pickpocket.Progress", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local finish = ply:GetNWFloat("DBS_PickpocketEnd", 0)
        if finish <= CurTime() then return end

        local start = ply:GetNWFloat("DBS_PickpocketStart", 0)
        local frac = math.Clamp((CurTime() - start) / math.max(0.1, finish - start), 0, 1)

        local w, h = 360, 58
        local x = (ScrW() - w) * 0.5
        local y = ScrH() * 0.78

        draw.RoundedBox(10, x, y, w, h, Color(14, 14, 18, 225))
        draw.SimpleText("Pickpocketing...", "DBS_UI_Body", x + 14, y + 16, color_white, TEXT_ALIGN_LEFT)
        draw.RoundedBox(6, x + 14, y + 34, w - 28, 14, Color(40, 40, 40, 180))
        draw.RoundedBox(6, x + 16, y + 36, (w - 32) * frac, 10, Color(80, 180, 120, 230))
    end)
end

function SWEP:PrimaryAttack()
    if not SERVER then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local pickTime = GetPickTimeForPlayer(ply)
    self:SetNextPrimaryFire(CurTime() + 1.2)

    if ply:GetNWFloat("DBS_NextPickPocket", 0) > CurTime() then
        DBS.Util.Notify(ply, "Lay low for a second before trying again.")
        return
    end

    local tr = ply:GetEyeTrace()
    local target = tr.Entity

    if not IsValid(target) then
        DBS.Util.Notify(ply, "No target.")
        return
    end

    if IsBlockedTarget(target) then
        DBS.Util.Notify(ply, "You can't pickpocket this NPC.")
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

    ply:SetNWFloat("DBS_PickpocketStart", CurTime())
    ply:SetNWFloat("DBS_PickpocketEnd", CurTime() + pickTime)

    ply:SetNWFloat("DBS_NextPickPocket", CurTime() + pickTime + 1.8)

    timer.Simple(pickTime, function()
        if not IsValid(ply) then return end

        ply:SetNWFloat("DBS_PickpocketEnd", 0)

        if not IsValid(target) then
            DBS.Util.Notify(ply, "Target moved.")
            return
        end

        if ply:GetPos():DistToSqr(target:GetPos()) > (PICK_RANGE * PICK_RANGE) then
            DBS.Util.Notify(ply, "Too far away to finish.")
            return
        end

        local level = math.max(1, ply:GetNWInt("DBS_PickpocketSkillLevel", 1))
        local successChance = GetPickSuccessChance(level, target:IsPlayer())
        local success = math.Rand(0, 1) <= successChance

        if not success then
            DBS.Util.Notify(ply, "You got spotted!")
            if target:IsPlayer() then
                DBS.Util.Notify(target, ply:Nick() .. " tried to pickpocket you!")
            end
            target:EmitSound("vo/npc/male01/gethellout.wav", 75, 105)
            return
        end

        local amount = GetStealAmount(target, level)
        if amount <= 0 then
            DBS.Util.Notify(ply, "Target has nothing worth taking.")
            return
        end

        if target:IsPlayer() then
            amount = math.min(amount, target:GetMoney())
            if amount <= 0 then
                DBS.Util.Notify(ply, "Target has nothing worth taking.")
                return
            end
            target:AddMoney(-amount)
        end

        ply:AddMoney(amount)
        DBS.Util.Notify(ply, "You lifted $" .. string.Comma(amount) .. ".")

        if target:IsPlayer() then
            DBS.Util.Notify(target, "You were pickpocketed for $" .. string.Comma(amount) .. ".")
        end
    end)
end
