DBS = DBS or {}
DBS.DrugDealer = DBS.DrugDealer or {}

util.AddNetworkString("DBS_Drugs_Open")
util.AddNetworkString("DBS_Drugs_Action")

function DBS.DrugDealer.Open(ply)
    net.Start("DBS_Drugs_Open")
        net.WriteInt(ply:GetNWInt("DBS_Drugs", 0), 16)
    net.Send(ply)
end

local function FindNearestDropbox(pos)
    local best, bestDist
    for _, ent in ipairs(ents.FindByClass("dbs_drug_dropbox")) do
        local d = pos:DistToSqr(ent:GetPos())
        if not bestDist or d < bestDist then
            best, bestDist = ent, d
        end
    end
    return best
end

net.Receive("DBS_Drugs_Action", function(_, ply)
    local action = net.ReadString()

    if action == "setup_meet" then
        local units = ply:GetNWInt("DBS_Drugs", 0)
        if units <= 0 then DBS.Util.Notify(ply, "You have no drugs to move.") return end

        local box = FindNearestDropbox(ply:GetPos())
        if not IsValid(box) then DBS.Util.Notify(ply, "No dropbox available.") return end

        ply:SetNWInt("DBS_DrugMeetUnits", units)
        ply:SetNWEntity("DBS_DrugMeetBox", box)
        ply:SetNWFloat("DBS_DrugMeetUntil", CurTime() + ((DBS.Config.Drugs and DBS.Config.Drugs.MeetDuration) or 180))

        DBS.Util.Notify(ply, "Meet set. Deliver to the dropbox before timer ends.")
        return
    end

    if action == "adm_givedrugs" and IsValid(ply) and ply:IsAdmin() then
        ply:SetNWInt("DBS_Drugs", ply:GetNWInt("DBS_Drugs", 0) + 10)
        DBS.Util.Notify(ply, "+10 drugs (admin test).")
    end
end)

function DBS.DrugDealer.TryDeliver(ply, box)
    if not IsValid(ply) then return end
    if ply:GetNWEntity("DBS_DrugMeetBox") ~= box then return end
    if ply:GetNWFloat("DBS_DrugMeetUntil", 0) < CurTime() then
        DBS.Util.Notify(ply, "Meet expired.")
        return
    end

    local units = ply:GetNWInt("DBS_DrugMeetUnits", 0)
    if units <= 0 then return end

    local cur = ply:GetNWInt("DBS_Drugs", 0)
    local moved = math.min(units, cur)
    if moved <= 0 then DBS.Util.Notify(ply, "No product to deliver.") return end

    local payout = moved * ((DBS.Config.Drugs and DBS.Config.Drugs.PayoutPerUnit) or 90)

    ply:SetNWInt("DBS_Drugs", cur - moved)
    ply:SetNWInt("DBS_DrugMeetUnits", 0)
    ply:SetNWEntity("DBS_DrugMeetBox", NULL)

    ply:AddMoney(payout)
    DBS.Util.Notify(ply, "Delivery complete: $" .. string.Comma(payout) .. ".")
end
