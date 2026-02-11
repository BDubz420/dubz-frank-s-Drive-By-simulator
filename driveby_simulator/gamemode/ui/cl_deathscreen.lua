if not CLIENT then return end

local deathMode = nil
local deathBy = ""
local deathAt = 0

surface.CreateFont("DBS_DEATH_Title", { font = "Roboto", size = 42, weight = 900 })
surface.CreateFont("DBS_DEATH_Body", { font = "Roboto", size = 22, weight = 500 })

net.Receive("DBS_DeathInfo", function()
    deathMode = net.ReadString()
    deathBy = net.ReadString()
    deathAt = CurTime()
end)

hook.Add("HUDPaint", "DBS.DeathScreen", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or ply:Alive() then return end
    if not deathMode then return end

    local alpha = math.Clamp((CurTime() - deathAt) * 180, 0, 220)

    draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(20, 0, 0, alpha))

    local title = (deathMode == "suicide") and "You Died" or "You Were Killed"
    local body = (deathMode == "suicide") and "Cause: Suicide" or ("Killed by: " .. deathBy)

    draw.SimpleText(title, "DBS_DEATH_Title", ScrW() * 0.5, ScrH() * 0.42, Color(240, 220, 220), TEXT_ALIGN_CENTER)
    draw.SimpleText(body, "DBS_DEATH_Body", ScrW() * 0.5, ScrH() * 0.48, Color(220, 200, 200), TEXT_ALIGN_CENTER)
    draw.SimpleText("Respawn and get back in the fight.", "DBS_DEATH_Body", ScrW() * 0.5, ScrH() * 0.54, Color(190, 170, 170), TEXT_ALIGN_CENTER)
end)
