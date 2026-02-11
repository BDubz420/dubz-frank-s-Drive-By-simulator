DBS = DBS or {}
DBS.PlayerRules = DBS.PlayerRules or {}

-- =========================
-- Movement tuning (slow, grounded)
-- =========================
DBS.PlayerRules.WalkSpeed     = 120
DBS.PlayerRules.RunSpeed      = 160
DBS.PlayerRules.SlowWalkSpeed = 90
DBS.PlayerRules.CrouchSpeed   = 0.2
DBS.PlayerRules.JumpPower     = 170

-- =========================
-- SERVER
-- =========================
if SERVER then

    hook.Add("PlayerSpawn", "DBS.ApplyPlayerMovement", function(ply)
        if not IsValid(ply) then return end

        ply:SetWalkSpeed(DBS.PlayerRules.WalkSpeed)
        ply:SetRunSpeed(DBS.PlayerRules.RunSpeed)
        ply:SetSlowWalkSpeed(DBS.PlayerRules.SlowWalkSpeed)
        ply:SetCrouchedWalkSpeed(DBS.PlayerRules.CrouchSpeed)
        ply:SetJumpPower(DBS.PlayerRules.JumpPower)
    end)

    -- Noclip only for superadmins
    hook.Add("PlayerNoClip", "DBS.NoClipControl", function(ply)
        return ply:IsSuperAdmin()
    end)

    -- Disable undo globally
    hook.Add("CanUndo", "DBS.BlockUndo", function()
        return false
    end)

end

-- =========================
-- CLIENT
-- =========================
if CLIENT then

    -- =========================
    -- Block Sandbox Menus
    -- =========================

    hook.Add("SpawnMenuOpen", "DBS.BlockSpawnMenu", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end

        -- Only admins can open Q menu
        return ply:IsAdmin()
    end)

    hook.Add("ContextMenuOpen", "DBS.BlockContextMenu", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end

        -- Only admins can open C menu
        return ply:IsAdmin()
    end)

    -- =========================
    -- Hide Sandbox HUD
    -- =========================
    hook.Add("HUDShouldDraw", "DBS.HideSandboxHUD", function(name)
        -- Ammo & suit are sandbox-y
        --if name == "CHudWeaponSelection" then return false end
        if name == "CHudAmmo" then return false end
        if name == "CHudSecondaryAmmo" then return false end
        if name == "CHudHealth" then return false end
        if name == "CHudBattery" then return false end

        return true
    end)
end