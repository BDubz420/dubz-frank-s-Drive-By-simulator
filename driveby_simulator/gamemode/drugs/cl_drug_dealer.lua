if not CLIENT then return end

local FRAME

net.Receive("DBS_Drugs_Open", function()
    local bricks = net.ReadInt(16)
    local supplyPrice = net.ReadInt(16)

    if IsValid(FRAME) then FRAME:Remove() end

    FRAME = vgui.Create("DFrame")
    FRAME:SetSize(440, 260)
    FRAME:Center()
    FRAME:SetTitle("Drug Dealer")
    FRAME:MakePopup()

    local lbl = vgui.Create("DLabel", FRAME)
    lbl:Dock(TOP)
    lbl:DockMargin(10, 10, 10, 10)
    lbl:SetText("Coke bricks in stash: " .. bricks .. "\nBuy supplies for processing, then set up a meet.")
    lbl:SetWrap(true)
    lbl:SetAutoStretchVertical(true)

    local supplies = vgui.Create("DButton", FRAME)
    supplies:Dock(TOP)
    supplies:DockMargin(10, 0, 10, 8)
    supplies:SetTall(32)
    supplies:SetText("Buy Supplies Case ($" .. string.Comma(supplyPrice) .. ")")
    supplies.DoClick = function()
        net.Start("DBS_Drugs_Action")
            net.WriteString("buy_supplies")
        net.SendToServer()
    end

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
end)

hook.Add("HUDPaint", "DBS.Drugs.DropboxMarker", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local box = ply:GetNWEntity("DBS_DrugMeetBox")
    local untilAt = ply:GetNWFloat("DBS_DrugMeetUntil", 0)
    if not IsValid(box) or untilAt <= CurTime() then return end

    local left = math.max(0, untilAt - CurTime())

    draw.SimpleText("Drug meet timer: " .. string.format("%.0fs", left), "DermaDefaultBold", ScrW() * 0.5, ScrH() * 0.08, Color(170, 255, 170), TEXT_ALIGN_CENTER)

    local screen = box:GetPos():ToScreen()
    if not screen.visible then return end

    draw.SimpleText("DROPBOX", "Trebuchet24", screen.x, screen.y - 16, Color(120, 255, 120), TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format("%.0fs", left), "DermaDefaultBold", screen.x, screen.y + 2, Color(220, 255, 220), TEXT_ALIGN_CENTER)
end)
