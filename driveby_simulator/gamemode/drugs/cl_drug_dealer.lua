if not CLIENT then return end

local FRAME

net.Receive("DBS_Drugs_Open", function()
    local units = net.ReadInt(16)

    if IsValid(FRAME) then FRAME:Remove() end

    FRAME = vgui.Create("DFrame")
    FRAME:SetSize(420, 220)
    FRAME:Center()
    FRAME:SetTitle("Drug Dealer")
    FRAME:MakePopup()

    local lbl = vgui.Create("DLabel", FRAME)
    lbl:Dock(TOP)
    lbl:DockMargin(10, 10, 10, 10)
    lbl:SetText("Drugs in stash: " .. units .. "\nSet up a meet, then deliver at the highlighted dropbox.")
    lbl:SetWrap(true)
    lbl:SetAutoStretchVertical(true)

    local btn = vgui.Create("DButton", FRAME)
    btn:Dock(TOP)
    btn:DockMargin(10, 0, 10, 8)
    btn:SetTall(32)
    btn:SetText("Set Up Meet")
    btn.DoClick = function()
        net.Start("DBS_Drugs_Action")
            net.WriteString("setup_meet")
        net.SendToServer()
        FRAME:Close()
    end

    local admin = vgui.Create("DButton", FRAME)
    admin:Dock(TOP)
    admin:DockMargin(10, 0, 10, 8)
    admin:SetTall(26)
    admin:SetText("Admin test: +10 drugs")
    admin.DoClick = function()
        net.Start("DBS_Drugs_Action")
            net.WriteString("adm_givedrugs")
        net.SendToServer()
    end
end)

hook.Add("HUDPaint", "DBS.Drugs.DropboxMarker", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local box = ply:GetNWEntity("DBS_DrugMeetBox")
    local untilAt = ply:GetNWFloat("DBS_DrugMeetUntil", 0)
    if not IsValid(box) or untilAt <= CurTime() then return end

    local screen = box:GetPos():ToScreen()
    if not screen.visible then return end

    local left = math.max(0, untilAt - CurTime())
    draw.SimpleText("DROPBOX", "Trebuchet24", screen.x, screen.y - 16, Color(120, 255, 120), TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format("%.0fs", left), "DermaDefaultBold", screen.x, screen.y + 2, Color(220, 255, 220), TEXT_ALIGN_CENTER)
end)
