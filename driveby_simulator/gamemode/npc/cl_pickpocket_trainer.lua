if not CLIENT then return end

net.Receive("DBS_Pickpocket_Open", function()
    local alreadyTrained = net.ReadBool()

    local frame = vgui.Create("DFrame")
    frame:SetSize(440, 260)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 14, 18, 240))
        draw.RoundedBox(12, 0, 0, w, 54, Color(20, 24, 30, 250))
        draw.SimpleText("Vinny's Pickpocket Lessons", "DBS_UI_Title", 16, 16, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("Steal fast. Keep moving. Never do it in front of cops.", "DBS_UI_Body", 16, 44, Color(180, 180, 180), TEXT_ALIGN_LEFT)
    end

    local content = frame:Add("DPanel")
    content:Dock(FILL)
    content:DockMargin(14, 70, 14, 14)
    content.Paint = nil

    local info = content:Add("DLabel")
    info:Dock(TOP)
    info:SetWrap(true)
    info:SetAutoStretchVertical(true)
    info:SetFont("DBS_UI_Body")
    info:SetTextColor(Color(220, 220, 220))
    info:SetText("Use the Pickpocket SWEP behind targets at close range. Works on players and NPCs. Success gives cash, failure alerts your target.")

    local btn = content:Add("DButton")
    btn:Dock(BOTTOM)
    btn:SetTall(38)
    btn:SetText("")
    btn.Paint = function(self, w, h)
        local c = alreadyTrained and Color(75, 75, 75) or (self:IsHovered() and Color(70, 150, 90) or Color(50, 120, 70))
        draw.RoundedBox(8, 0, 0, w, h, c)
        draw.SimpleText(alreadyTrained and "Already Trained" or "Learn Pickpocket (+SWEP)", "DBS_UI_Body", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btn:SetEnabled(not alreadyTrained)

    btn.DoClick = function()
        net.Start("DBS_Pickpocket_Learn")
        net.SendToServer()
        frame:Remove()
    end
end)
