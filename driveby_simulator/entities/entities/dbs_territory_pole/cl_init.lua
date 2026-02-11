include("shared.lua")

surface.CreateFont("DBS_TERR_Title", {
    font = "Roboto",
    size = 22,
    weight = 800
})

surface.CreateFont("DBS_TERR_Body", {
    font = "Roboto",
    size = 16,
    weight = 500
})

local function GetTeamColor(teamID)
    if teamID == DBS.Const.Teams.RED then return Color(220, 60, 60) end
    if teamID == DBS.Const.Teams.BLUE then return Color(60, 120, 220) end
    if teamID == DBS.Const.Teams.POLICE then return Color(80, 160, 220) end
    return Color(190, 190, 190)
end

hook.Add("HUDPaint", "DBS_TerritoryCaptureHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local teamID = ply:Team()
    if teamID == 0 or teamID == TEAM_UNASSIGNED then return end

    local radius = (DBS.Config and DBS.Config.TerritoryPole and DBS.Config.TerritoryPole.Radius) or 300
    local radiusSqr = radius * radius

    local activePole
    for _, ent in ipairs(ents.FindByClass("dbs_territory_pole")) do
        if not IsValid(ent) then continue end
        if ent:GetCapturingTeam() ~= teamID then continue end
        if ply:GetPos():DistToSqr(ent:GetPos()) > radiusSqr then continue end
        activePole = ent
        break
    end


    if not IsValid(activePole) then

    local noMoneyUntil = ply:GetNWFloat("DBS_TerritoryNoMoneyUntil", 0)
    if noMoneyUntil > CurTime() then
        local nearest = nil
        for _, ent in ipairs(ents.FindByClass("dbs_territory_pole")) do
            if IsValid(ent) and ply:GetPos():DistToSqr(ent:GetPos()) <= radiusSqr then
                nearest = ent
                break
            end
        end

        if IsValid(nearest) and not IsValid(activePole) then
            local cost = ply:GetNWInt("DBS_TerritoryNoMoneyCost", 0)
            local w, h = 520, 38
            local x = (ScrW() - w) * 0.5
            local y = 40
            draw.RoundedBox(10, x, y, w, h, Color(14, 14, 18, 228))
            draw.SimpleText("Cannot claim territory: need $" .. string.Comma(cost), "DBS_TERR_Body", x + w * 0.5, y + h * 0.5, Color(255, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
        return
    end

    local endTime = activePole:GetCaptureEndsAt()
    if endTime <= 0 then return end

    local start = activePole:GetNWFloat("DBS_CaptureStart", 0)
    local total = math.max(1, endTime - start)
    local frac = math.Clamp((CurTime() - start) / total, 0, 1)
    local remaining = math.max(0, math.ceil(endTime - CurTime()))

    local w, h = 560, 92
    local x = (ScrW() - w) * 0.5
    local y = 28

    local accent = GetTeamColor(teamID)

    draw.RoundedBox(12, x, y, w, h, Color(14, 14, 18, 228))
    draw.RoundedBox(12, x + 10, y + 10, 8, h - 20, accent)

    draw.SimpleText("CAPTURING TERRITORY", "DBS_TERR_Title", x + 28, y + 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Progress: " .. math.floor(frac * 100) .. "%  |  " .. remaining .. "s", "DBS_TERR_Body", x + 28, y + 44, Color(190, 190, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Hold ring for bonus payout. Team also gets split income.", "DBS_TERR_Body", x + 28, y + 62, Color(165, 200, 165), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    draw.RoundedBox(6, x + 300, y + 40, 240, 14, Color(40, 40, 40, 180))
    draw.RoundedBox(6, x + 302, y + 42, 236 * frac, 10, accent)
end)
