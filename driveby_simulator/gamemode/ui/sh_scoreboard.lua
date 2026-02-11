-- gamemode/player/sh_scoreboard.lua

if not CLIENT then return end

local SCOREBOARD

-- =========================
-- Fonts
-- =========================
surface.CreateFont("DBS_SB_Title", {
    font = "Roboto",
    size = 28,
    weight = 800
})

surface.CreateFont("DBS_SB_Header", {
    font = "Roboto",
    size = 18,
    weight = 700
})

surface.CreateFont("DBS_SB_Player", {
    font = "Roboto",
    size = 16,
    weight = 500
})

-- =========================
-- Helpers
-- =========================
local function TeamName(teamID)
    if teamID == DBS.Const.Teams.RED then return "Red Team" end
    if teamID == DBS.Const.Teams.BLUE then return "Blue Team" end
    if teamID == DBS.Const.Teams.POLICE then return "Police" end
    return "Unassigned"
end

local function TeamCount(teamID)
    local count = 0
    for _, ply in ipairs(player.GetAll()) do
        if teamID == 0 then
            if ply:Team() == 0 or ply:Team() == TEAM_UNASSIGNED then
                count = count + 1
            end
        elseif ply:Team() == teamID then
            count = count + 1
        end
    end
    return count
end

local function TeamColor(teamID)
    if teamID == DBS.Const.Teams.RED then return Color(200, 60, 60) end
    if teamID == DBS.Const.Teams.BLUE then return Color(60, 120, 200) end
    if teamID == DBS.Const.Teams.POLICE then return Color(60, 160, 200) end
    return Color(150, 150, 150)
end

-- =========================
-- Player Row
-- =========================
local function CreatePlayerRow(parent, ply, index)
    local row = parent:Add("DPanel")
    row:SetTall(26)
    row:Dock(TOP)
    row:DockMargin(4, 2, 4, 2)

    local isLocal = ply == LocalPlayer()
    local alt = index % 2 == 0

    row.Paint = function(self, w, h)
        local bg

        if isLocal then
            bg = Color(60, 120, 180, 220)
        elseif alt then
            bg = Color(25, 25, 25, 200)
        else
            bg = Color(20, 20, 20, 200)
        end

        draw.RoundedBox(4, 0, 0, w, h, bg)

        draw.SimpleText(
            ply:Nick(),
            "DBS_SB_Player",
            8,
            h / 2,
            color_white,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        local cred = ply:GetNWInt("DBS_Cred", 0)
        local money = ply:GetNWInt("DBS_Money", 0)

        draw.SimpleText(
            "CRED: " .. cred,
            "DBS_SB_Player",
            w - 140,
            h / 2,
            Color(120, 160, 255),
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            "$" .. string.Comma(money),
            "DBS_SB_Player",
            w - 10,
            h / 2,
            Color(120, 220, 120),
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER
        )
    end

    return row
end

-- =========================
-- Column
-- =========================
local function CreateTeamColumn(parent, teamID)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(LEFT)
    panel:DockMargin(6, 0, 6, 0)

    panel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(10, 10, 10, 220))

        local name = TeamName(teamID)
        local count = TeamCount(teamID)

        draw.SimpleText(
            name .. " (" .. count .. ")",
            "DBS_SB_Header",
            w / 2,
            10,
            TeamColor(teamID),
            TEXT_ALIGN_CENTER
        )
    end

    local scroll = panel:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(6, 36, 6, 6)

    panel.Scroll = scroll
    panel.TeamID = teamID

    return panel
end

-- =========================
-- Build Scoreboard
-- =========================
local function BuildScoreboard()
    SCOREBOARD = vgui.Create("DFrame")
    SCOREBOARD:SetSize(ScrW() * 0.85, ScrH() * 0.85)
    SCOREBOARD:Center()
    SCOREBOARD:SetTitle("")
    SCOREBOARD:ShowCloseButton(false)
    SCOREBOARD:SetDraggable(false)
    SCOREBOARD:MakePopup()

    SCOREBOARD.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(15, 15, 15, 240))
        draw.SimpleText("Dubz & Frank's DriveBy Simulator", "DBS_SB_Title", w / 2, 12, color_white, TEXT_ALIGN_CENTER)
    end

    local body = vgui.Create("DPanel", SCOREBOARD)
    body:Dock(FILL)
    body:DockMargin(16, 56, 16, 40)
    body.Paint = nil

    local columns = {
        CreateTeamColumn(body, DBS.Const.Teams.RED),
        CreateTeamColumn(body, DBS.Const.Teams.BLUE),
        CreateTeamColumn(body, DBS.Const.Teams.POLICE),
        CreateTeamColumn(body, 0)
    }

    -- IMPORTANT: set widths after Derma lays out body
    body.PerformLayout = function(self, w, h)
        local gap = 12 -- left+right margin per column (6 + 6)
        local totalGaps = gap * #columns

        local colW = math.floor((w - totalGaps) / #columns)
        local remainder = (w - totalGaps) - (colW * #columns)

        for i, col in ipairs(columns) do
            local extra = (i == #columns) and remainder or 0
            col:SetWide(colW + extra)
        end
    end

    -- Populate players
    for _, col in ipairs(columns) do
        col.Scroll:Clear()
    end

    local rowIndex = {
        [DBS.Const.Teams.RED] = 0,
        [DBS.Const.Teams.BLUE] = 0,
        [DBS.Const.Teams.POLICE] = 0,
        [0] = 0
    }

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then continue end

        local teamID = ply:Team()
        if teamID == TEAM_UNASSIGNED then teamID = 0 end

        for _, col in ipairs(columns) do
            if col.TeamID == teamID then
                rowIndex[teamID] = rowIndex[teamID] + 1
                CreatePlayerRow(col.Scroll, ply, rowIndex[teamID])
                break
            end
        end
    end

    -- Footer
    local footer = vgui.Create("DLabel", SCOREBOARD)
    footer:Dock(BOTTOM)
    footer:SetTall(24)
    footer:SetContentAlignment(5)
    footer:SetText("Online players: " .. #player.GetAll() .. "/" .. game.MaxPlayers())
end

-- =========================
-- Hooks
-- =========================
function GM:ScoreboardShow()
    if IsValid(SCOREBOARD) then SCOREBOARD:Remove() end
    BuildScoreboard()
end

function GM:ScoreboardHide()
    if IsValid(SCOREBOARD) then
        SCOREBOARD:Remove()
    end
end
