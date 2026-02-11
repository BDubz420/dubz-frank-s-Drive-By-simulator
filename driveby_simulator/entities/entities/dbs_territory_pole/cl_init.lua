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

    if not IsValid(activePole) then return end

    local endTime = activePole:GetCaptureEndsAt()
    if endTime <= 0 then return end

    local capMin = (DBS.Config.Territory and DBS.Config.Territory.CaptureTimeMin) or 60
    local capMax = (DBS.Config.Territory and DBS.Config.Territory.CaptureTimeMax) or capMin
    local total = math.max(1, capMax)
    local start = endTime - total
    local frac = math.Clamp((CurTime() - start) / total, 0, 1)
    local remaining = math.max(0, math.ceil(endTime - CurTime()))

    local w, h = 500, 74
    local x = (ScrW() - w) * 0.5
    local y = 28

    local accent = GetTeamColor(teamID)

    draw.RoundedBox(12, x, y, w, h, Color(14, 14, 18, 228))
    draw.RoundedBox(12, x + 10, y + 10, 8, h - 20, accent)

    draw.SimpleText("CAPTURING TERRITORY", "DBS_TERR_Title", x + 28, y + 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Hold the block... " .. remaining .. "s", "DBS_TERR_Body", x + 28, y + 44, Color(190, 190, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    draw.RoundedBox(6, x + 250, y + 40, 230, 14, Color(40, 40, 40, 180))
    draw.RoundedBox(6, x + 252, y + 42, 226 * frac, 10, accent)
end)
