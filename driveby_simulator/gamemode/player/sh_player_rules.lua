DBS = DBS or {}
DBS.PlayerRules = DBS.PlayerRules or {}

-- Slower, heavier movement for realism
DBS.PlayerRules.WalkSpeed     = 95
DBS.PlayerRules.RunSpeed      = 104
DBS.PlayerRules.SlowWalkSpeed = 70
DBS.PlayerRules.CrouchSpeed   = 0.18
DBS.PlayerRules.JumpPower     = 155

if SERVER then
    hook.Add("PlayerSpawn", "DBS.ApplyPlayerMovement", function(ply)
        if not IsValid(ply) then return end
        ply:SetWalkSpeed(DBS.PlayerRules.WalkSpeed)
        ply:SetRunSpeed(DBS.PlayerRules.RunSpeed)
        ply:SetSlowWalkSpeed(DBS.PlayerRules.SlowWalkSpeed)
        ply:SetCrouchedWalkSpeed(DBS.PlayerRules.CrouchSpeed)
        ply:SetJumpPower(DBS.PlayerRules.JumpPower)
    end)

    hook.Add("PlayerNoClip", "DBS.NoClipControl", function(ply)
        return ply:IsSuperAdmin() or (ply:IsAdmin() and ply:GetNWBool("DBS_SandboxMode", false))
    end)

    hook.Add("PlayerSay", "DBS.AdminSandboxToggle", function(ply, text)
        local msg = string.lower(string.Trim(text or ""))
        if msg ~= "!sandbox" and msg ~= "/sandbox" then return end
        if not ply:IsAdmin() then return "" end

        local newState = not ply:GetNWBool("DBS_SandboxMode", false)
        ply:SetNWBool("DBS_SandboxMode", newState)
        DBS.Util.Notify(ply, "Sandbox mode " .. (newState and "enabled" or "disabled") .. ".")
        return ""
    end)

    hook.Add("CanTool", "DBS.SandboxCanTool", function(ply)
        if not IsValid(ply) then return false end
        if not ply:IsAdmin() then return false end
        return ply:GetNWBool("DBS_SandboxMode", false)
    end)

    hook.Add("PhysgunPickup", "DBS.SandboxPhysgun", function(ply)
        if not IsValid(ply) then return false end
        if not ply:IsAdmin() then return false end
        return ply:GetNWBool("DBS_SandboxMode", false)
    end)

    hook.Add("CanUndo", "DBS.BlockUndo", function(ply)
        if not IsValid(ply) then return false end
        if not ply:IsAdmin() then return false end
        return ply:GetNWBool("DBS_SandboxMode", false)
    end)
end

if CLIENT then
    hook.Add("SpawnMenuOpen", "DBS.BlockSpawnMenu", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:IsAdmin() and ply:GetNWBool("DBS_SandboxMode", false)
    end)

    hook.Add("ContextMenuOpen", "DBS.BlockContextMenu", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:IsAdmin() and ply:GetNWBool("DBS_SandboxMode", false)
    end)

    hook.Add("HUDShouldDraw", "DBS.HideSandboxHUD", function(name)
        if name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudHealth" or name == "CHudBattery" then
            return false
        end
        return true
    end)
end
