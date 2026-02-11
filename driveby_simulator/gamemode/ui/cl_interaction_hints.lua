if not CLIENT then return end

surface.CreateFont("DBS_HINT", { font = "Roboto", size = 16, weight = 500 })
surface.CreateFont("DBS_TUTORIAL", { font = "Roboto", size = 18, weight = 700 })

local tutorialEnd = 0
local tutorialShown = false

hook.Add("InitPostEntity", "DBS.StartTutorialHints", function()
    if cookie.GetString("dbs_tutorial_seen", "0") == "1" then return end
    tutorialEnd = CurTime() + 40
    tutorialShown = true
    cookie.Set("dbs_tutorial_seen", "1")
end)

hook.Add("HUDPaint", "DBS.InteractionHints", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    if tutorialEnd > CurTime() then
        local w, h = 500, 92
        local x = (ScrW() - w) * 0.5
        local y = ScrH() * 0.12
        draw.RoundedBox(8, x, y, w, h, Color(10, 12, 16, 205))
        draw.SimpleText("Welcome to DriveBy Simulator", "DBS_TUTORIAL", x + 16, y + 16, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("F2: Property Menu  •  R (Police + stunstick): Arrest", "DBS_HINT", x + 16, y + 44, Color(210, 210, 210), TEXT_ALIGN_LEFT)
        draw.SimpleText("Chat: !red / !blue / !police", "DBS_HINT", x + 16, y + 66, Color(180, 180, 180), TEXT_ALIGN_LEFT)
    end

    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then return end

    local ent = tr.Entity
    local hint

    if DBS.Doors and DBS.Doors.IsDoor and DBS.Doors.IsDoor(ent) then
        hint = "Manage property"
    elseif ent:GetClass() == "dbs_npc_eli" then
        hint = "Talk to dealer"
    elseif ent:GetClass() == "dbs_npc_jerome" then
        hint = "Talk to team rep"
    elseif ent:GetClass() == "dbs_npc_pickpocket_trainer" then
        hint = "Talk to trainer"
    elseif ent:GetClass() == "dbs_npc_car_dealer" then
        hint = "Talk to car dealer"
    elseif ent:GetClass() == "dbs_npc_drug_dealer" then
        hint = "Talk to dealer"
    elseif ent:GetClass() == "dbs_drug_dropbox" then
        hint = "Use dropbox"
    end

    if not hint then return end

    local w, h = 190, 26
    local x = (ScrW() - w) * 0.5
    local y = ScrH() * 0.70

    draw.RoundedBox(6, x, y, w, h, Color(12, 12, 15, 160))
    draw.SimpleText(hint, "DBS_HINT", x + w * 0.5, y + h * 0.5, Color(235, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)
