include("shared.lua")

hook.Remove("HUDPaint", "DBS_TerritoryCaptureHUD")

local CAPTURE_TIME = 60

local function GetTeamColor(teamID)
    if teamID == DBS.Const.Teams.RED then return Color(220, 60, 60) end
    if teamID == DBS.Const.Teams.BLUE then return Color(60, 120, 220) end
    if teamID == DBS.Const.Teams.POLICE then return Color(80, 160, 220) end
    return Color(255, 255, 255)
end

hook.Add("HUDPaint", "DBS_TerritoryCaptureHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local teamID = ply:Team()
    if teamID == 0 or teamID == TEAM_UNASSIGNED then return end

    local radius = (DBS.Config and DBS.Config.TerritoryPole and DBS.Config.TerritoryPole.Radius) or 300
    local radiusSqr = radius * radius

    -- Find a pole you are actively capturing AND you are inside its radius
    local pole
    for _, ent in ipairs(ents.FindByClass("dbs_territory_pole")) do
        if not IsValid(ent) then continue end
        if ent:GetCapturingTeam() ~= teamID then continue end
        if ply:GetPos():DistToSqr(ent:GetPos()) > radiusSqr then continue end
        pole = ent
        break
    end

    if not IsValid(pole) then return end

    local endTime = pole:GetCaptureEndsAt()
    if endTime <= 0 then return end

    local startTime = endTime - CAPTURE_TIME
    local frac = math.Clamp((CurTime() - startTime) / CAPTURE_TIME, 0, 1)

    local w, h = 520, 10
    local x = (ScrW() - w) * 0.5
    local y = 40

    local col = GetTeamColor(teamID)

    -- back
    draw.RoundedBox(6, x, y, w, h, Color(20, 20, 20, 230))
    -- fill
    draw.RoundedBox(6, x + 2, y + 2, (w - 4) * frac, h - 4, col)

    draw.SimpleText("CAPTURING TERRITORY", "DermaDefaultBold", x + w * 0.5, y - 14, color_white, TEXT_ALIGN_CENTER)
end)
