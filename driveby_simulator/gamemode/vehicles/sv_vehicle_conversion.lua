DBS.Vehicles = DBS.Vehicles or {}

function DBS.Vehicles.SetOwnerTeam(veh, teamId)
    veh:SetNWInt("DBS_OwnerTeam", teamId)

    if DBS.Config.Vehicles.UseTeamColors and DBS.Teams.Definitions[teamId] then
        local c = DBS.Teams.Definitions[teamId].color
        veh:SetColor(c)
    end
end

function DBS.Vehicles.HandleConversion(ply, veh)
    local owner = veh:GetNWInt("DBS_OwnerTeam", 0)
    local plyTeam = ply:Team()

    -- Enemy conversion reward
    if owner ~= 0 and owner ~= plyTeam then
        DBS.Vehicles.SetOwnerTeam(veh, plyTeam)
        ply:AddMoney(DBS.Config.Cars.Reward.EnemyCarMoney)
        ply:AddCred(DBS.Config.Cars.Reward.EnemyCarCred)
        return true
    end

    return false
end
