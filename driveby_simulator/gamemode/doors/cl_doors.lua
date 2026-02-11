if not CLIENT then return end

surface.CreateFont("DBS_Door_Title", {
    font = "Roboto",
    size = 24,
    weight = 700
})

surface.CreateFont("DBS_Door_Info", {
    font = "Roboto",
    size = 18,
    weight = 500
})

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
    local teamColor = DBS.Doors.GetTeamColor(owner)

    local buyCost = cfg.BuyCost or 0
    local refund = math.floor(buyCost * (cfg.SellRefundPercent or 0))

    local actionText = "[E] Buy property ($" .. string.Comma(buyCost) .. ")"
    if owner == ply:Team() and owner ~= 0 then
        actionText = "[Shift + E] Sell property ($" .. string.Comma(refund) .. ")"
    elseif owner ~= 0 then
        actionText = "Property is locked to " .. team.GetName(owner)
    end

    local w, h = 420, 96
    local x = (ScrW() - w) * 0.5
    local y = ScrH() * 0.72

    draw.RoundedBox(10, x, y, w, h, Color(12, 12, 12, 220))
    draw.RoundedBox(10, x + 8, y + 8, 8, h - 16, teamColor)

    draw.SimpleText(DBS.Doors.GetOwnerLabel(owner), "DBS_Door_Title", x + 28, y + 18, teamColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(actionText, "DBS_Door_Info", x + 28, y + 58, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)
