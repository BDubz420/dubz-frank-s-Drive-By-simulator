if not CLIENT then return end

DBS = DBS or {}
DBS.TerritoryRender = DBS.TerritoryRender or {}

local function GetPoleColor(pole)
    local owner = pole:GetOwnerTeam()
    local state = pole:GetState()

    -- contested overrides
    if state == (DBS.Const and DBS.Const.TerritoryState and DBS.Const.TerritoryState.CONTESTED or 2) then
        return Color(170, 80, 255, 90) -- purple
    end

    if owner == 0 then
        return Color(200, 200, 200, 70) -- neutral
    end

    if owner == TEAM_RED then
        return Color(255, 80, 80, 90)
    end

    if owner == TEAM_BLUE then
        return Color(80, 80, 255, 90)
    end

    return Color(200, 200, 200, 70)
end

-- simple ring cylinder
local function DrawTerritoryRing(pos, radius, col)
    -- Use engine-provided debug overlay style ring (rendered clientside)
    -- We do this with a poly "beam ring" so it looks clean and cheap.
    local segments = 48
    local step = (math.pi * 2) / segments

    render.SetColorMaterial()

    local last = nil
    for i = 0, segments do
        local a = i * step
        local p = pos + Vector(math.cos(a) * radius, math.sin(a) * radius, 8)

        if last then
            render.DrawLine(last, p, col, true)
        end
        last = p
    end
end

hook.Add("PostDrawTranslucentRenderables", "DBS.DrawTerritoryZones", function()
    if not DBS.Config or not DBS.Config.TerritoryPole then return end

    local radius = DBS.Config.TerritoryPole.Radius or 300
    local poles = ents.FindByClass("dbs_territory_pole")
    if not poles then return end

    local lp = LocalPlayer()
    if IsValid(lp) then
        -- distance cull so we don't draw across the whole map
        -- feel free to tune this
        local maxDistSqr = (2500 * 2500)

        for _, pole in ipairs(poles) do
            if not IsValid(pole) then continue end

            local pos = pole:GetPos()
            if lp:GetPos():DistToSqr(pos) > maxDistSqr then continue end

            local col = GetPoleColor(pole)
            DrawTerritoryRing(pos, radius, col)
        end
    end
end)
