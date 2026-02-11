if not CLIENT then return end

surface.CreateFont("DBS_UI_Title", {
    font = "Roboto",
    size = 24,
    weight = 800
})

surface.CreateFont("DBS_UI_Body", {
    font = "Roboto",
    size = 17,
    weight = 500
})

local function SendDoorAction(door, action)
    net.Start("DBS_Doors_Action")
        net.WriteEntity(door)
        net.WriteString(action)
    net.SendToServer()
end

local function BuildButton(parent, text, color, doClick)
    local btn = parent:Add("DButton")
    btn:Dock(TOP)
    btn:SetTall(34)
    btn:DockMargin(0, 0, 0, 8)
    btn:SetText("")

    btn.Paint = function(self, w, h)
        local bg = self:IsHovered() and Color(math.min(color.r + 25, 255), math.min(color.g + 25, 255), math.min(color.b + 25, 255), 255) or color
        draw.RoundedBox(8, 0, 0, w, h, bg)
        draw.SimpleText(text, "DBS_UI_Body", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    btn.DoClick = doClick

    return btn
end

local function OpenDoorMenu(door)
    if not IsValid(door) then return end

    local owner = DBS.Doors.GetOwnerTeam(door)
    local ownerColor = DBS.Doors.GetTeamColor(owner)

    local frame = vgui.Create("DFrame")
    frame:SetSize(430, LocalPlayer():IsAdmin() and 340 or 255)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(true)
    frame:MakePopup()

    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 14, 18, 240))
        draw.RoundedBox(12, 0, 0, w, 56, Color(20, 24, 30, 250))
        draw.RoundedBox(12, 10, 10, 8, 36, ownerColor)
        draw.SimpleText("Property Control", "DBS_UI_Title", 30, 20, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText(DBS.Doors.GetOwnerLabel(owner), "DBS_UI_Body", 30, 43, Color(180, 180, 180), TEXT_ALIGN_LEFT)
    end

    local body = frame:Add("DPanel")
    body:Dock(FILL)
    body:DockMargin(14, 68, 14, 12)
    body.Paint = nil

    local cfg = DBS.Config.Property and DBS.Config.Property.Door or {}
    local buyCost = cfg.BuyCost or 0
    local refund = math.floor(buyCost * (cfg.SellRefundPercent or 0))

    BuildButton(body, "Buy Property ($" .. string.Comma(buyCost) .. ")", Color(50, 120, 70, 255), function()
        SendDoorAction(door, "buy")
        frame:Remove()
    end)

    BuildButton(body, "Sell Property ($" .. string.Comma(refund) .. ")", Color(110, 70, 40, 255), function()
        SendDoorAction(door, "sell")
        frame:Remove()
    end)

    local info = body:Add("DLabel")
    info:Dock(TOP)
    info:SetWrap(true)
    info:SetAutoStretchVertical(true)
    info:SetText("Tip: Use F2 while looking at a door to manage it.")
    info:SetTextColor(Color(180, 180, 180))
    info:SetFont("DBS_UI_Body")

    if LocalPlayer():IsAdmin() then
        local separator = body:Add("DPanel")
        separator:Dock(TOP)
        separator:SetTall(8)
        separator:DockMargin(0, 6, 0, 6)
        separator.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, h * 0.5, w, 1, Color(70, 70, 70))
        end

        BuildButton(body, "Admin: Set Bloodz Owner", Color(155, 45, 45, 255), function()
            SendDoorAction(door, "set_red")
            frame:Remove()
        end)

        BuildButton(body, "Admin: Set Cripz Owner", Color(40, 75, 165, 255), function()
            SendDoorAction(door, "set_blue")
            frame:Remove()
        end)

        BuildButton(body, "Admin: Set Police Owner", Color(45, 120, 160, 255), function()
            SendDoorAction(door, "set_police")
            frame:Remove()
        end)

        BuildButton(body, "Admin: Set Unowned", Color(90, 90, 90, 255), function()
            SendDoorAction(door, "set_unowned")
            frame:Remove()
        end)
    end
end


local function TryOpenDoorMenuFromTrace(ply)
    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then return false end

    local door = tr.Entity
    if not DBS.Doors.IsDoor(door) then return false end

    local cfg = DBS.Config.Property and DBS.Config.Property.Door or {}
    local maxDist = cfg.InteractionDistance or 140
    if ply:GetPos():DistToSqr(door:GetPos()) > (maxDist * maxDist) then
        chat.AddText(Color(80, 200, 255), "[DBS] ", color_white, "Move closer to this door.")
        return true
    end

    OpenDoorMenu(door)
    return true
end

hook.Add("PlayerButtonDown", "DBS.Doors.F2Menu", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if button ~= KEY_F2 then return end

    TryOpenDoorMenuFromTrace(ply)
end)

hook.Add("PlayerBindPress", "DBS.Doors.F2Intercept", function(ply, bind, pressed)
    if not pressed then return end
    if string.find(string.lower(bind), "gm_showteam", 1, true) then
        if TryOpenDoorMenuFromTrace(ply) then
            return true
        end
    end
end)

hook.Add("HUDPaint", "DBS.Doors.ContextPrompt", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then return end

    local door = tr.Entity
    if not DBS.Doors or not DBS.Doors.IsDoor or not DBS.Doors.IsDoor(door) then return end

    local cfg = DBS.Config.Property and DBS.Config.Property.Door or {}
    local maxDist = cfg.InteractionDistance or 140
    if ply:GetPos():DistToSqr(door:GetPos()) > (maxDist * maxDist) then return end

    local owner = DBS.Doors.GetOwnerTeam(door)
    local ownerColor = DBS.Doors.GetTeamColor(owner)

    local w, h = 400, 72
    local x = (ScrW() - w) * 0.5
    local y = ScrH() * 0.76

    draw.RoundedBox(10, x, y, w, h, Color(14, 14, 18, 220))
    draw.RoundedBox(10, x + 8, y + 8, 8, h - 16, ownerColor)

    draw.SimpleText(DBS.Doors.GetOwnerLabel(owner), "DBS_UI_Title", x + 24, y + 18, ownerColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Press F2 to manage this property", "DBS_UI_Body", x + 24, y + 50, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)
