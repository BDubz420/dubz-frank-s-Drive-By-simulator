if CLIENT then
    surface.CreateFont("DBS_HUD_Title", {
        font = "Roboto",
        size = 20,
        weight = 700
    })

    surface.CreateFont("DBS_HUD_Value", {
        font = "Roboto",
        size = 30,
        weight = 900
    })

    surface.CreateFont("DBS_HUD_Small", {
        font = "Roboto",
        size = 16,
        weight = 500
    })

    local function GetTeamPanelColor(teamID)
        if teamID == DBS.Const.Teams.RED then return Color(200, 60, 60, 240) end
        if teamID == DBS.Const.Teams.BLUE then return Color(60, 110, 220, 240) end
        if teamID == DBS.Const.Teams.POLICE then return Color(70, 160, 220, 240) end
        return Color(150, 150, 150, 240)
    end

    hook.Add("HUDPaint", "DBS.OverhauledHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        local money = ply:GetMoney()
        local cred = (DBS.Player and DBS.Player.GetCred and DBS.Player.GetCred(ply)) or ply:GetNWInt("DBS_Cred", 0)
        local kills = ply:Frags()

        local x = 24
        local y = ScrH() - 160
        local w = 380
        local h = 132

        draw.RoundedBox(10, x, y, w, h, Color(10, 10, 10, 220))
        draw.RoundedBox(10, x + 8, y + 8, 10, h - 16, GetTeamPanelColor(ply:Team()))

        draw.SimpleText(team.GetName(ply:Team()) or "Unassigned", "DBS_HUD_Title", x + 28, y + 22, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("$" .. string.Comma(money), "DBS_HUD_Value", x + 28, y + 58, Color(120, 220, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.SimpleText("CRED: " .. cred, "DBS_HUD_Small", x + 250, y + 48, Color(135, 170, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("KILLS: " .. kills, "DBS_HUD_Small", x + 250, y + 74, Color(235, 170, 110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local econ = DBS.Config.Economy or {}
        local softCap = econ.SoftWalletCap or 0
        if softCap > 0 then
            draw.SimpleText("Soft cap: $" .. string.Comma(softCap), "DBS_HUD_Small", x + 28, y + 105, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end)
end
