if not CLIENT then return end

local PICKPOCKET_FRAME

net.Receive("DBS_Pickpocket_Open", function()
    local trainedPick = net.ReadBool()
    local trainedLock = net.ReadBool()
    local pickLevel = net.ReadUInt(3)
    local lockLevel = net.ReadUInt(3)
    local pickUnlocked = net.ReadUInt(3)
    local lockUnlocked = net.ReadUInt(3)
    local cred = net.ReadUInt(6)

    local nextPickCred = net.ReadUInt(6)
    local nextPickCost = net.ReadInt(32)
    local nextLockCred = net.ReadUInt(6)
    local nextLockCost = net.ReadInt(32)

    if IsValid(PICKPOCKET_FRAME) then PICKPOCKET_FRAME:Remove() end

    local frame = vgui.Create("DFrame")
    frame:SetSize(560, 360)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()

    PICKPOCKET_FRAME = frame
    frame.OnRemove = function() PICKPOCKET_FRAME = nil end

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 14, 18, 240))
        draw.RoundedBox(12, 0, 0, w, 54, Color(20, 24, 30, 250))
        draw.SimpleText("Vinny's Training", "DBS_UI_Title", 16, 16, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("CRED: " .. cred .. "   |   Skill cap: Level 5", "DBS_UI_Body", 16, 44, Color(180, 180, 180), TEXT_ALIGN_LEFT)
    end

    local scroll = frame:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(14, 70, 14, 14)

    local info = scroll:Add("DLabel")
    info:Dock(TOP)
    info:SetWrap(true)
    info:SetAutoStretchVertical(true)
    info:SetFont("DBS_UI_Body")
    info:SetTextColor(Color(220, 220, 220))
    info:SetText("Pickpocket level: " .. pickLevel .. "/5\nLockpick level: " .. lockLevel .. "/5\nHigher levels improve speed and reliability.")

    local pickBtn = scroll:Add("DButton")
    pickBtn:Dock(TOP)
    pickBtn:DockMargin(0, 12, 0, 8)
    pickBtn:SetTall(44)
    pickBtn:SetText("")
    pickBtn.Paint = function(self, w, h)
        local canBuy = pickUnlocked > pickLevel
        local c = canBuy and (self:IsHovered() and Color(70, 150, 90) or Color(50, 120, 70)) or Color(75, 75, 75)
        draw.RoundedBox(8, 0, 0, w, h, c)
        local txt
        if not trainedPick then
            txt = "Learn Pickpocket Lv.1 (Free)"
        elseif pickLevel >= 5 then
            txt = "Pickpocket Maxed (Lv.5)"
        else
            txt = ("Upgrade Pickpocket to Lv.%d (Cost: $%s, CRED %d)"):format(pickLevel + 1, string.Comma(nextPickCost), nextPickCred)
        end
        draw.SimpleText(txt, "DBS_UI_Body", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    pickBtn.DoClick = function()
        net.Start("DBS_Pickpocket_Learn")
            net.WriteString("pickpocket")
        net.SendToServer()
    end

    local lockBtn = scroll:Add("DButton")
    lockBtn:Dock(TOP)
    lockBtn:SetTall(44)
    lockBtn:SetText("")
    lockBtn.Paint = function(self, w, h)
        local canBuy = lockUnlocked > lockLevel
        local c = canBuy and (self:IsHovered() and Color(55, 120, 165) or Color(45, 95, 140)) or Color(75, 75, 75)
        draw.RoundedBox(8, 0, 0, w, h, c)
        local txt
        if not trainedLock then
            txt = "Learn Lockpick Lv.1 (Cost: $250, CRED 0)"
        elseif lockLevel >= 5 then
            txt = "Lockpick Maxed (Lv.5)"
        else
            local target = math.min(lockLevel + 1, 5)
            local cost = nextLockCost
            local reqCred = nextLockCred
            txt = ("Upgrade Lockpick to Lv.%d (Cost: $%s, CRED %d)"):format(target, string.Comma(cost), reqCred)
        end
        draw.SimpleText(txt, "DBS_UI_Body", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    lockBtn.DoClick = function()
        net.Start("DBS_Pickpocket_Learn")
            net.WriteString("lockpick")
        net.SendToServer()
    end
end)
