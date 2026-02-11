if not CLIENT then return end

local pulseUntil = 0

surface.CreateFont("DBS_KO_HINT", { font = "Roboto", size = 22, weight = 600 })

net.Receive("DBS_HurtPulse", function()
    pulseUntil = CurTime() + 0.35
end)

hook.Add("HUDPaint", "DBS.DamageEdgeEffect", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local maxHp = math.max(1, ply:GetMaxHealth())
    local hpFrac = math.Clamp(ply:Health() / maxHp, 0, 1)

    local base = (1 - hpFrac) * 120
    if pulseUntil > CurTime() then
        base = base + (pulseUntil - CurTime()) * 240
    end

    local a = math.Clamp(base, 0, 180)
    if a <= 3 then return end

    local col = Color(120, 8, 8, a)
    local w, h = ScrW(), ScrH()

    draw.RoundedBox(0, 0, 0, 60, h, col)
    draw.RoundedBox(0, w - 60, 0, 60, h, col)
    draw.RoundedBox(0, 0, 0, w, 36, Color(80, 0, 0, a * 0.4))
    draw.RoundedBox(0, 0, h - 36, w, 36, Color(80, 0, 0, a * 0.4))
end)

hook.Add("HUDPaint", "DBS.KnockoutBlackout", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if not ply:GetNWBool("DBS_IsKnockedOut", false) then return end

    local endAt = ply:GetNWFloat("DBS_KOEndsAt", CurTime() + 1)
    local left = math.max(0, endAt - CurTime())

    local blink = 25 + math.abs(math.sin(CurTime() * 3.5)) * 65
    local fadeOut = math.Clamp(left * 10, 0, 120)
    local alpha = math.Clamp(180 + blink - fadeOut, 120, 245)

    draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, alpha))
    draw.SimpleText("Unconscious", "DBS_KO_HINT", ScrW() * 0.5, ScrH() * 0.55, Color(180, 180, 180, alpha), TEXT_ALIGN_CENTER)
end)
