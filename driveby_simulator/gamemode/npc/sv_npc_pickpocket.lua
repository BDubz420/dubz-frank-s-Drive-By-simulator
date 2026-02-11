DBS = DBS or {}
DBS.PickpocketTrainer = DBS.PickpocketTrainer or {}

util.AddNetworkString("DBS_Pickpocket_Open")
util.AddNetworkString("DBS_Pickpocket_Learn")

function DBS.PickpocketTrainer.Open(ply)
    if not IsValid(ply) then return end

    net.Start("DBS_Pickpocket_Open")
        net.WriteBool(ply:GetNWBool("DBS_TrainedPickpocket", false))
    net.Send(ply)
end

net.Receive("DBS_Pickpocket_Learn", function(_, ply)
    if not IsValid(ply) then return end

    if ply:GetNWBool("DBS_TrainedPickpocket", false) then
        DBS.Util.Notify(ply, "You're already trained.")
        return
    end

    ply:SetNWBool("DBS_TrainedPickpocket", true)
    ply:Give("weapon_dbs_pickpocket")

    DBS.Util.Notify(ply, "Vinny taught you how to pickpocket. Don't get caught.")
end)
