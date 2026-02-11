DBS.Court = DBS.Court or {}

local function SpawnCourthouse(ply)
    -- For now, reuse Intro until you add courthouse spawn config
    DBS.Player.SpawnIntro(ply)
end

function DBS.Court.CalculateMinutes(kills)
    local mins = math.floor(kills / DBS.Config.Court.KillsPerMinute)
    return math.Clamp(mins, 0, DBS.Config.Court.MaxMinutes)
end

function DBS.Court.HandleArrest(victim, cop)
    if not IsValid(victim) then return end

    local kills = victim:GetNWInt("DBS_KillsThisLife", 0)
    local minutes = DBS.Court.CalculateMinutes(kills)

    victim:SetNWInt("DBS_SentenceMinutes", minutes)

    timer.Simple(0, function()
        if not IsValid(victim) then return end
        SpawnCourthouse(victim)

        -- Tell client: kills + sentence minutes
        net.Start(DBS.Net.OpenMayor)
            net.WriteUInt(kills, 8)
            net.WriteUInt(minutes, 8)
        net.Send(victim)
    end)
end

-- Mayor buttons: 0 = OK, 1 = AttemptEscape
net.Receive(DBS.Net.MayorChoice, function(_, ply)
    if not IsValid(ply) then return end

    local choice = net.ReadUInt(2)
    local minutes = ply:GetNWInt("DBS_SentenceMinutes", 0)
    if minutes <= 0 then
        -- No sentence: just go home
        DBS.Player.SpawnHQ(ply)
        return
    end

    if choice == 0 then
        DBS.Jail.SendToJail(ply, minutes)
        ply:KillSilent()
        ply:Spawn()
        return
    end

    if choice == 1 then
        -- Start escape minigame
        local minN = DBS.Config.Court.EscapeGuessMin
        local maxN = DBS.Config.Court.EscapeGuessMax
        ply:SetNWInt("DBS_EscapeSecret", math.random(minN, maxN))

        net.Start(DBS.Net.Notify)
            net.WriteString(("Escape attempt: guess a number %d-%d."):format(minN, maxN))
        net.Send(ply)
        return
    end
end)

net.Receive(DBS.Net.EscapeGuess, function(_, ply)
    if not IsValid(ply) then return end

    local guess = net.ReadUInt(8)
    local secret = ply:GetNWInt("DBS_EscapeSecret", -1)
    local minutes = ply:GetNWInt("DBS_SentenceMinutes", 0)

    if secret == -1 or minutes <= 0 then return end

    ply:SetNWInt("DBS_EscapeSecret", -1)

    if guess == secret then
        net.Start(DBS.Net.Notify)
            net.WriteString("Escape SUCCESS. You're back at HQ.")
        net.Send(ply)

        DBS.Player.SpawnHQ(ply)
    else
        net.Start(DBS.Net.Notify)
            net.WriteString(("Escape FAILED. Serving %d minute(s)."):format(minutes))
        net.Send(ply)

        DBS.Jail.SendToJail(ply, minutes)
        ply:KillSilent()
        ply:Spawn()
    end
end)
