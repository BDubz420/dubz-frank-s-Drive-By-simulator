if not CLIENT then return end

local SCOREBOARD

surface.CreateFont("DBS_SB_Title", {
    font = "Roboto",
    size = 30,
    weight = 900
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

local function TeamCount(teamID)
    local count = 0
    for _, ply in ipairs(player.GetAll()) do
        if ply:Team() == teamID then
            count = count + 1
        end
    end
    return count
end

local function TeamColor(teamID)
    return team.GetColor(teamID) or Color(160, 160, 160)
end

local function SortedPlayers(teamID)
    local players = team.GetPlayers(teamID)
    table.sort(players, function(a, b)
        return a:Frags() > b:Frags()
    end)
    return players
end

local function CreatePlayerRow(parent, ply, index)
    local row = parent:Add("DPanel")
    row:SetTall(28)
    row:Dock(TOP)
    row:DockMargin(4, 2, 4, 2)

    local isLocal = ply == LocalPlayer()
    local alt = index % 2 == 0

    row.Paint = function(self, w, h)
        local bg = isLocal and Color(55, 95, 145, 230) or (alt and Color(25, 25, 25, 210) or Color(18, 18, 18, 210))

        draw.RoundedBox(4, 0, 0, w, h, bg)
        draw.SimpleText(ply:Nick(), "DBS_SB_Player", 8, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.SimpleText("C " .. ply:GetNWInt("DBS_Cred", 0), "DBS_SB_Player", w - 198, h * 0.5, Color(130, 165, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("$" .. string.Comma(ply:GetMoney()), "DBS_SB_Player", w - 150, h * 0.5, Color(125, 225, 125), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("K " .. ply:Frags(), "DBS_SB_Player", w - 78, h * 0.5, Color(235, 180, 110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(tostring(ply:Ping()), "DBS_SB_Player", w - 10, h * 0.5, Color(180, 180, 180), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    return row
end

local function CreateTeamColumn(parent, teamID)
    local panel = vgui.Create("DPanel", parent)
    panel:Dock(LEFT)
    panel:DockMargin(6, 0, 6, 0)

    panel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(10, 10, 10, 220))
        draw.SimpleText(team.GetName(teamID) .. " (" .. TeamCount(teamID) .. ")", "DBS_SB_Header", w * 0.5, 12, TeamColor(teamID), TEXT_ALIGN_CENTER)
        draw.SimpleText("CRED / MONEY / KILLS / PING", "DBS_SB_Player", w * 0.5, 32, Color(180, 180, 180), TEXT_ALIGN_CENTER)
    end

    local scroll = panel:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(6, 50, 6, 6)

    panel.TeamID = teamID
    panel.Scroll = scroll

    return panel
end

local function BuildScoreboard()
    SCOREBOARD = vgui.Create("DFrame")
    SCOREBOARD:SetSize(ScrW() * 0.9, ScrH() * 0.86)
    SCOREBOARD:Center()
    SCOREBOARD:SetTitle("")
    SCOREBOARD:ShowCloseButton(false)
    SCOREBOARD:SetDraggable(false)
    SCOREBOARD:MakePopup()

    SCOREBOARD.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(15, 15, 15, 245))
        draw.SimpleText("Dubz & Frank's DriveBy Simulator", "DBS_SB_Title", w * 0.5, 18, color_white, TEXT_ALIGN_CENTER)
    end

    local body = vgui.Create("DPanel", SCOREBOARD)
    body:Dock(FILL)
    body:DockMargin(16, 64, 16, 40)
    body.Paint = nil

    local teamsToRender = {
        DBS.Const.Teams.RED,
        DBS.Const.Teams.BLUE,
        DBS.Const.Teams.POLICE
    }

    local columns = {}
    for _, teamID in ipairs(teamsToRender) do
        table.insert(columns, CreateTeamColumn(body, teamID))
    end

    body.PerformLayout = function(self, w)
        local gap = 12
        local totalGaps = gap * #columns
        local colW = math.floor((w - totalGaps) / #columns)

        for _, col in ipairs(columns) do
            col:SetWide(colW)
        end
    end

    for _, col in ipairs(columns) do
        col.Scroll:Clear()

        for i, ply in ipairs(SortedPlayers(col.TeamID)) do
            CreatePlayerRow(col.Scroll, ply, i)
        end
    end

    local footer = vgui.Create("DLabel", SCOREBOARD)
    footer:Dock(BOTTOM)
    footer:SetTall(26)
    footer:SetContentAlignment(5)
    footer:SetText("Players online: " .. #player.GetAll() .. "/" .. game.MaxPlayers())
end

function GM:ScoreboardShow()
    if IsValid(SCOREBOARD) then SCOREBOARD:Remove() end
    BuildScoreboard()
end

function GM:ScoreboardHide()
    if IsValid(SCOREBOARD) then SCOREBOARD:Remove() end
end
