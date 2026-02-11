if CLIENT then

    surface.CreateFont("DBS_HUD_Small", {
        font = "Roboto",
        size = 18,
        weight = 500
    })

    surface.CreateFont("DBS_HUD_Large", {
        font = "Roboto",
        size = 22,
        weight = 700
    })

    hook.Add("HUDPaint", "DBS.BasicHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        if not ply:Alive() then return end

        -- Pull values (adjust getters if needed)
        local money = ply:GetNWInt("DBS_Money", 0)
        local cred  = ply:GetNWInt("DBS_Cred", 0)

        local x = 24
        local y = ScrH() - 90

        -- Background
        draw.RoundedBox(6, x - 12, y - 12, 220, 64, Color(15, 15, 15, 200))

        -- Money
        draw.SimpleText("Money", "DBS_HUD_Small", x, y, Color(180, 180, 180))
        draw.SimpleText("$" .. string.Comma(money), "DBS_HUD_Large", x, y + 16, Color(120, 220, 120))

        -- Cred
        draw.SimpleText("CRED", "DBS_HUD_Small", x + 120, y, Color(180, 180, 180))
        draw.SimpleText(tostring(cred), "DBS_HUD_Large", x + 120, y + 16, Color(120, 160, 255))
    end)

end
