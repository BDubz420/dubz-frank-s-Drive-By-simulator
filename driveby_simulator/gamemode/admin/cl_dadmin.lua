if not CLIENT then return end

local FRAME

local function SendAction(action, sid)
    net.Start("DBS_DAdmin_Action")
        net.WriteString(action)
        net.WriteString(sid)
    net.SendToServer()
end

net.Receive("DBS_DAdmin_Open", function()
    local rows = net.ReadTable() or {}

    if IsValid(FRAME) then FRAME:Remove() end

    FRAME = vgui.Create("DFrame")
    FRAME:SetSize(560, 440)
    FRAME:Center()
    FRAME:SetTitle("Dubz Admin")
    FRAME:MakePopup()

    local sheet = vgui.Create("DPropertySheet", FRAME)
    sheet:Dock(FILL)

    local playersTab = vgui.Create("DScrollPanel")
    sheet:AddSheet("Players", playersTab, "icon16/user.png")

    for _, row in ipairs(rows) do
        local pnl = playersTab:Add("DPanel")
        pnl:Dock(TOP)
        pnl:DockMargin(4, 4, 4, 0)
        pnl:SetTall(30)
        pnl.Paint = function(self,w,h)
            draw.RoundedBox(4,0,0,w,h,Color(25,25,25,220))
            draw.SimpleText(row.Name, "DermaDefaultBold", 8, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local actions = {"freeze","jail","kick","ban"}
        local x = 220
        for _, a in ipairs(actions) do
            local b = vgui.Create("DButton", pnl)
            b:SetPos(x, 4)
            b:SetSize(70, 22)
            b:SetText(a)
            b.DoClick = function() SendAction(a, row.SID) end
            x = x + 78
        end
    end

    local cmds = vgui.Create("DPanel")
    sheet:AddSheet("Keybinds/Commands", cmds, "icon16/keyboard.png")
    cmds:DockPadding(8, 8, 8, 8)

    local txt = vgui.Create("DLabel", cmds)
    txt:Dock(FILL)
    txt:SetWrap(true)
    txt:SetText([[Keys:
F1 = Toggle third person
F2 = Door/property menu
R (with stunstick as police) = Arrest suspect

Commands:
!red / !blue / !police
!dadmin (admin menu)
dbs_join_team <red|blue|police>
dbs_setjailpos / dbs_addjailpos

Admin sandbox toggle:
!sandbox]])
end)
