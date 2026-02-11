-- Driver cannot shoot
hook.Add("StartCommand", "DBS.DriverNoShoot", function(ply, cmd)
    if not IsValid(ply) then return end
    if not ply:InVehicle() then return end

    local veh = ply:GetVehicle()
    if not IsValid(veh) then return end
    if veh:GetDriver() ~= ply then return end

    if cmd:KeyDown(IN_ATTACK) or cmd:KeyDown(IN_ATTACK2) then
        cmd:RemoveKey(IN_ATTACK)
        cmd:RemoveKey(IN_ATTACK2)
    end
end)

-- HQ delivery payout (simple proximity check)
timer.Create("DBS.VehicleDeliveryThink", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:InVehicle() then continue end

        local veh = ply:GetVehicle()
        if not IsValid(veh) or veh:GetDriver() ~= ply then continue end

        local hq = DBS.Config.Spawns.HQ[ply:Team()]
        if not hq or not hq.DeliveryPos then continue end

        local dist = ply:GetPos():Distance(hq.DeliveryPos)
        if dist <= (hq.DeliveryRadius or 220) then
            -- prevent spam payouts
            if veh:GetNWFloat("DBS_LastDelivery", 0) > (CurTime() - 10) then continue end
            veh:SetNWFloat("DBS_LastDelivery", CurTime())

            ply:AddMoney(DBS.Config.Cars.Reward.HQDeliveryMoney)
            net.Start(DBS.Net.Notify)
                net.WriteString(("+$%d for vehicle delivery."):format(DBS.Config.Cars.Reward.HQDeliveryMoney))
            net.Send(ply)
        end
    end
end)
