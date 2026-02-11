local function OpenJeromeMenu()
    if IsValid(DBS_JEROME_FRAME) then
        DBS_JEROME_FRAME:Remove()
    end

    local w, h = 420, 300

    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("Jerome")
    frame:MakePopup()
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)

    DBS_JEROME_FRAME = frame

    local label = vgui.Create("DLabel", frame)
    label:SetText("So who you gonna represent?")
    label:SetFont("DermaLarge")
    label:SizeToContents()
    label:SetPos(40, 40)

    local function MakeButton(text, teamID, y)
        local btn = vgui.Create("DButton", frame)
        btn:SetSize(w - 80, 40)
        btn:SetPos(40, y)
        btn:SetText(text)
        btn:SetFont("DermaDefaultBold")

        btn.DoClick = function()
            net.Start("DBS_Jerome_SelectTeam")
            net.WriteUInt(teamID, 4)
            net.SendToServer()
            frame:Close()
        end
    end

    MakeButton("Red Gang",   DBS.Const.Teams.RED,    120)
    MakeButton("Blue Gang",  DBS.Const.Teams.BLUE,   170)
    MakeButton("Police",     DBS.Const.Teams.POLICE, 220)
end

net.Receive("DBS_Jerome_Open", OpenJeromeMenu)
