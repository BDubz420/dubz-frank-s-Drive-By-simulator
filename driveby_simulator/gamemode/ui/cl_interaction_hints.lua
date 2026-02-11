if not CLIENT then return end

surface.CreateFont("DBS_HINT", { font = "Roboto", size = 18, weight = 600 })

hook.Add("HUDPaint", "DBS.InteractionHints", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local tr = ply:GetEyeTrace()
    if not tr or not IsValid(tr.Entity) then return end

    local ent = tr.Entity
    local hint

    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep:GetClass() == "weapon_stunstick" and ent:IsPlayer() and DBS.Util and DBS.Util.IsPolice and DBS.Util.IsPolice(ply) then
        hint = "R: Arrest suspect  |  F1: Camera"
    elseif DBS.Doors and DBS.Doors.IsDoor and DBS.Doors.IsDoor(ent) then
        hint = "F2: Property Menu"
    elseif ent:GetClass() == "dbs_npc_eli" then
        hint = "E: Open Dealer"
    elseif ent:GetClass() == "dbs_npc_jerome" then
        hint = "E: Choose Team"
    elseif ent:GetClass() == "dbs_npc_pickpocket_trainer" then
        hint = "E: Learn Pickpocket"
    elseif ent:GetClass() == "dbs_npc_car_dealer" then
        hint = "E: Car Dealer / Auction"
    elseif ent:GetClass() == "dbs_npc_drug_dealer" then
        hint = "E: Drug Deals"
    elseif ent:GetClass() == "dbs_drug_dropbox" then
        hint = "E: Deliver Drug Package"
    elseif ent:GetClass() == "dbs_npc_judge" then
        hint = "Judge NPC"
    end

    if not hint then return end

    local w, h = 260, 32
    local x = (ScrW() - w) * 0.5
    local y = ScrH() * 0.68

    draw.RoundedBox(8, x, y, w, h, Color(12, 12, 15, 210))
    draw.SimpleText(hint, "DBS_HINT", x + w * 0.5, y + h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)
