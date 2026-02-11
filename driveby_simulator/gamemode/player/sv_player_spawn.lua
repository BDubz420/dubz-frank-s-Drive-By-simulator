DBS = DBS or {}
DBS.Player = DBS.Player or {}

-- Route police kills to court
hook.Add("PlayerDeath", "DBS.RouteToCourt", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not DBS.Util.IsPolice(attacker) then return end

    victim.DBS_SendToCourt = true
end)

-- Initialize persistent stats
hook.Add("PlayerInitialSpawn", "DBS.InitPlayerStats", function(ply)
    DBS.Player.SetCred(ply, tonumber(ply:GetPData("dbs_cred", 0)) or 0)
    DBS.Player.SetMoney(ply, tonumber(ply:GetPData("dbs_money", 250)) or 250)
    ply:SetNWBool("DBS_TrainedLockpick", ply:GetPData("dbs_trained_lockpick", "0") == "1")
    ply:SetNWBool("DBS_TrainedPickpocket", ply:GetPData("dbs_trained_pickpocket", "0") == "1")
    ply:SetNWInt("DBS_PickpocketSkillLevel", tonumber(ply:GetPData("dbs_pickpocket_lvl", 1)) or 1)
    ply:SetNWInt("DBS_LockpickSkillLevel", tonumber(ply:GetPData("dbs_lockpick_lvl", 1)) or 1)
end)

-- Core spawn handler
hook.Add("PlayerSpawn", "DBS.PlayerSpawn", function(ply)
    if not IsValid(ply) then return end

    ----------------------------------------------------------------
    -- HARD RESET (prevents sandbox defaults)
    ----------------------------------------------------------------
    ply:StripWeapons()
    ply:StripAmmo()

    ----------------------------------------------------------------
    -- BASE LOADOUT (everyone always has these)
    ----------------------------------------------------------------
    ply:Give("weapon_fists")
    ply:Give("weapon_dbs_hands")

    if ply:GetNWBool("DBS_TrainedLockpick", false) then
        ply:Give("weapon_dbs_lockpick")
    end

    if ply:GetNWBool("DBS_HasKeys", false) and not ply:HasWeapon("weapon_dbs_keys") then
        ply:Give("weapon_dbs_keys")
    end

    if ply:GetNWBool("DBS_TrainedPickpocket", false) then
        ply:Give("weapon_dbs_pickpocket")
    end

    ply:SelectWeapon("weapon_dbs_hands")

    ----------------------------------------------------------------
    -- DELAYED SPAWN LOGIC (after engine setup)
    ----------------------------------------------------------------
    timer.Simple(0, function()
        if not IsValid(ply) then return end

        ----------------------------------------------------------------
        -- COURT HAS HIGHEST PRIORITY
        ----------------------------------------------------------------
        if ply.DBS_SendToCourt then
            ply.DBS_SendToCourt = nil
            ply.DBS_InCourt = true
            DBS.Court.SendPlayer(ply)
            return
        end

        if ply.DBS_InCourt then
            ply.DBS_InCourt = nil
            DBS.Player.SpawnCourt(ply)
            return
        end

        ----------------------------------------------------------------
        -- JAIL (sentence already assigned)
        ----------------------------------------------------------------
        if ply.DBS_JailTime and ply.DBS_JailTime > 0 then
            DBS.Jail.Send(ply)
            return
        end

        ----------------------------------------------------------------
        -- INTRO OR HQ
        ----------------------------------------------------------------
        if ply:Team() == TEAM_UNASSIGNED or ply:Team() == 0 then
            DBS.Player.SpawnIntro(ply)
        else
            DBS.Player.SpawnHQ(ply)
        end
    end)
end)
