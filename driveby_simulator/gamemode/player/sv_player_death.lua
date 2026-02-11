DBS = DBS or {}
DBS.Player = DBS.Player or {}

-- =========================
-- Handle Player Death
-- =========================
hook.Add("PlayerDeath", "DBS.PlayerDeathCore", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end

    -- =========================
    -- DROP WEAPONS
    -- =========================
    for _, wep in ipairs(victim:GetWeapons()) do
        if IsValid(wep) then
            local class = wep:GetClass()

            -- Skip blacklisted weapons
            if not DBS.Config.WeaponDropBlacklist[class] then
                local drop = ents.Create(class)
                if IsValid(drop) then
                    drop:SetPos(victim:GetPos() + VectorRand() * 10 + Vector(0, 0, 20))
                    drop:SetAngles(AngleRand())
                    drop:Spawn()
                end
            end
        end
    end

    victim:StripWeapons()

    -- =========================
    -- DROP MONEY
    -- =========================
    local money = DBS.Player.GetMoney(victim)
    if money and money > 0 then
        local cash = ents.Create("dbs_money_drop")
        if IsValid(cash) then
            cash:SetPos(victim:GetPos() + Vector(0, 0, 15))
            cash:SetAmount(money)
            cash:Spawn()
        end
    end

    DBS.Player.SetMoney(victim, 0)

    -- =========================
    -- RESET CRED
    -- =========================
    DBS.Player.SetCred(victim, 0)
end)

-- =========================
-- Gang Kill → Cred Progression
-- =========================
hook.Add("PlayerDeath", "DBS.CredOnKill", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker == victim then return end
    if DBS.Util.IsPolice(attacker) then return end

    local kills = attacker:GetNWInt("DBS_Kills", 0) + 1
    attacker:SetNWInt("DBS_Kills", kills)

    if kills % 5 == 0 then
        DBS.Player.AddCred(attacker, 1)
        attacker:ChatPrint("[DBS] Cred increased to " .. DBS.Player.GetCred(attacker))
    end
end)

-- =========================
-- Police Kill Tracking
-- =========================
hook.Add("PlayerDeath", "DBS.PoliceKillTrack", function(victim, inflictor, attacker)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker == victim then return end
    if not DBS.Util.IsPolice(attacker) then return end

    local pk = attacker:GetNWInt("DBS_PoliceKills", 0) + 1
    attacker:SetNWInt("DBS_PoliceKills", pk)
end)
