if not CLIENT then return end

local PICKPOCKET_FRAME

net.Receive("DBS_Pickpocket_Open", function()
    local trainedPick = net.ReadBool()
    local trainedLock = net.ReadBool()
    local level = net.ReadUInt(3)
    local targetLevel = net.ReadUInt(3)
    local durationTenths = net.ReadUInt(8)

    if IsValid(PICKPOCKET_FRAME) then
        PICKPOCKET_FRAME:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(520, 340)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()

    PICKPOCKET_FRAME = frame
    frame.OnRemove = function() PICKPOCKET_FRAME = nil end

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 14, 18, 240))
        draw.RoundedBox(12, 0, 0, w, 54, Color(20, 24, 30, 250))
        draw.SimpleText("Vinny's Training", "DBS_UI_Title", 16, 16, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("Pay for skills and upgrade when your CRED rises.", "DBS_UI_Body", 16, 44, Color(180, 180, 180), TEXT_ALIGN_LEFT)
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
    info:SetText(("Pickpocket level: %d / %d\nCurrent channel time: %.1fs\nHigher level means faster pickpocketing."):format(level, targetLevel, durationTenths / 10))

    local pickBtn = content:Add("DButton")
    pickBtn:Dock(TOP)
    pickBtn:DockMargin(0, 12, 0, 8)
    pickBtn:SetTall(42)
    pickBtn:SetText("")
    pickBtn.Paint = function(self, w, h)
        local canUpgrade = (not trainedPick) or (targetLevel > level)
        local c = canUpgrade and (self:IsHovered() and Color(70, 150, 90) or Color(50, 120, 70)) or Color(75, 75, 75)
        draw.RoundedBox(8, 0, 0, w, h, c)
        local txt = "Learn Pickpocket"
        if trainedPick then
            txt = canUpgrade and ("Upgrade Pickpocket to Lv." .. targetLevel) or "Pickpocket Maxed for current CRED"
        end
        draw.SimpleText(txt, "DBS_UI_Body", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    pickBtn.DoClick = function()
        net.Start("DBS_Pickpocket_Learn")
            net.WriteString("pickpocket")
        net.SendToServer()
    end

    local lockBtn = content:Add("DButton")
    lockBtn:Dock(TOP)
    lockBtn:SetTall(40)
    lockBtn:SetText("")
    lockBtn.Paint = function(self, w, h)
        local c = trainedLock and Color(75, 75, 75) or (self:IsHovered() and Color(55, 120, 165) or Color(45, 95, 140))
        draw.RoundedBox(8, 0, 0, w, h, c)
        draw.SimpleText(trainedLock and "Lockpick Trained" or "Learn Lockpick ($cheap)", "DBS_UI_Body", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    lockBtn.DoClick = function()
        if trainedLock then return end
        net.Start("DBS_Pickpocket_Learn")
            net.WriteString("lockpick")
        net.SendToServer()
    end
end)
