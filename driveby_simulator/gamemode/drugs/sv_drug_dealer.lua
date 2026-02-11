DBS = DBS or {}
DBS.DrugDealer = DBS.DrugDealer or {}

util.AddNetworkString("DBS_Drugs_Open")
util.AddNetworkString("DBS_Drugs_Action")

local function SupplyPrice()
    return math.max(50, tonumber((DBS.Config.Drugs and DBS.Config.Drugs.SupplyPrice) or 300) or 300)
end

function DBS.DrugDealer.Open(ply)
    net.Start("DBS_Drugs_Open")
        net.WriteInt(ply:GetNWInt("DBS_CokeBricks", 0), 16)
        net.WriteInt(SupplyPrice(), 16)
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

    if action == "buy_supplies" then
        local price = SupplyPrice()
        if not ply:CanAfford(price) then DBS.Util.Notify(ply, "Can't afford supplies case.") return end
        local ent = ents.Create("dbs_coke_supply")
        if not IsValid(ent) then return end
        ent:SetPos(ply:GetPos() + ply:GetForward() * 30 + Vector(0, 0, 20))
        ent:Spawn()
        ply:AddMoney(-price)
        DBS.Util.Notify(ply, "Bought coke supplies for $" .. string.Comma(price) .. ".")
        DBS.DrugDealer.Open(ply)
        return
    end

    if action == "setup_meet" then
        local units = ply:GetNWInt("DBS_CokeBricks", 0)
        if units <= 0 then DBS.Util.Notify(ply, "You have no coke bricks to move.") return end

        local box = FindNearestDropbox(ply:GetPos())
        if not IsValid(box) then DBS.Util.Notify(ply, "No dropbox available.") return end

        ply:SetNWInt("DBS_DrugMeetUnits", units)
        ply:SetNWEntity("DBS_DrugMeetBox", box)
        ply:SetNWFloat("DBS_DrugMeetUntil", CurTime() + ((DBS.Config.Drugs and DBS.Config.Drugs.MeetDuration) or 180))

        DBS.Util.Notify(ply, "Meet set. Deliver to the marked dropbox before timer ends.")
        return
    end

    if action == "adm_givedrugs" and IsValid(ply) and ply:IsAdmin() then
        local brick = ents.Create("dbs_coke_brick")
        if IsValid(brick) then
            brick:SetPos(ply:GetPos() + ply:GetForward() * 30 + Vector(0,0,20))
            brick:Spawn()
            DBS.Util.Notify(ply, "Spawned test coke brick.")
        end
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

    local cur = ply:GetNWInt("DBS_CokeBricks", 0)
    local moved = math.min(units, cur)
    if moved <= 0 then DBS.Util.Notify(ply, "No product to deliver.") return end

    local payout = moved * ((DBS.Config.Drugs and DBS.Config.Drugs.PayoutPerUnit) or 90)

    ply:SetNWInt("DBS_CokeBricks", cur - moved)
    ply:SetNWInt("DBS_DrugMeetUnits", 0)
    ply:SetNWEntity("DBS_DrugMeetBox", NULL)

    ply:AddMoney(payout)

    local credCfg = DBS.Config.Cred or {}
    local credUnits = credCfg.CredForLargeDeliveryUnits or 18
    if moved >= credUnits then
        DBS.Player.AddCred(ply, 1)
        DBS.Util.Notify(ply, "Delivery complete: $" .. string.Comma(payout) .. " and +1 CRED.")
    else
        DBS.Util.Notify(ply, "Delivery complete: $" .. string.Comma(payout) .. ".")
    end
end
