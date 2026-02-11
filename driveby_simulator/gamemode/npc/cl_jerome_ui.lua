local function MakeTeamButton(parent, label, color, teamID)
    local btn = parent:Add("DButton")
    btn:Dock(TOP)
    btn:SetTall(40)
    btn:DockMargin(0, 0, 0, 8)
    btn:SetText("")

    btn.Paint = function(self, w, h)
        local bg = self:IsHovered() and Color(math.min(color.r + 20, 255), math.min(color.g + 20, 255), math.min(color.b + 20, 255), 255) or color
        draw.RoundedBox(8, 0, 0, w, h, bg)
        draw.SimpleText(label, "DBS_UI_Body", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    btn.DoClick = function()
        net.Start("DBS_Jerome_SelectTeam")
            net.WriteUInt(teamID, 4)
        net.SendToServer()

        if IsValid(DBS_JEROME_FRAME) then
            DBS_JEROME_FRAME:Close()
        end
    end

    return btn
end

local function OpenJeromeMenu()
    if IsValid(DBS_JEROME_FRAME) then
        DBS_JEROME_FRAME:Remove()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(450, 310)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 14, 18, 242))
        draw.RoundedBox(12, 0, 0, w, 58, Color(20, 24, 30, 250))
        draw.SimpleText("Choose Your Side", "DBS_UI_Title", 16, 18, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("Pick carefully. This city remembers.", "DBS_UI_Body", 16, 45, Color(180, 180, 180), TEXT_ALIGN_LEFT)
    end

    local body = frame:Add("DPanel")
    body:Dock(FILL)
    body:DockMargin(14, 68, 14, 12)
    body.Paint = nil

    MakeTeamButton(body, "Join Red Gang", Color(155, 45, 45), DBS.Const.Teams.RED)
    MakeTeamButton(body, "Join Blue Gang", Color(40, 75, 165), DBS.Const.Teams.BLUE)
    MakeTeamButton(body, "Join Police", Color(45, 120, 160), DBS.Const.Teams.POLICE)

    local hint = body:Add("DLabel")
    hint:Dock(TOP)
    hint:SetFont("DBS_UI_Body")
    hint:SetTextColor(Color(180, 180, 180))
    hint:SetText("Hint: Buy doors with F2 and build your base.")
    hint:SizeToContentsY()

    DBS_JEROME_FRAME = frame
end

net.Receive("DBS_Jerome_Open", OpenJeromeMenu)
