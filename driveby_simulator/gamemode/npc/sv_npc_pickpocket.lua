DBS = DBS or {}
DBS.PickpocketTrainer = DBS.PickpocketTrainer or {}

util.AddNetworkString("DBS_Pickpocket_Open")
util.AddNetworkString("DBS_Pickpocket_Learn")

local function GetLevelForCred(cred)
    return math.Clamp((tonumber(cred) or 0) + 1, 1, 5)
end

local function GetPickpocketDuration(level)
    return math.Clamp(3.8 - (level - 1) * 0.55, 1.4, 3.8)
end

function DBS.PickpocketTrainer.Open(ply)
    if not IsValid(ply) then return end

    local trainedPick = ply:GetNWBool("DBS_TrainedPickpocket", false)
    local trainedLock = ply:GetNWBool("DBS_TrainedLockpick", false)
    local level = math.max(1, ply:GetNWInt("DBS_PickpocketSkillLevel", 1))
    local targetLevel = GetLevelForCred(DBS.Player.GetCred(ply))

    net.Start("DBS_Pickpocket_Open")
        net.WriteBool(trainedPick)
        net.WriteBool(trainedLock)
        net.WriteUInt(level, 3)
        net.WriteUInt(targetLevel, 3)
        net.WriteUInt(math.Round(GetPickpocketDuration(level) * 10), 8)
    net.Send(ply)
end

net.Receive("DBS_Pickpocket_Learn", function(_, ply)
    if not IsValid(ply) then return end

    local action = net.ReadString()

    if action == "lockpick" then
        local fee = math.max(50, tonumber(DBS.Config.LockpickTrainingCost) or 250)
        if ply:GetNWBool("DBS_TrainedLockpick", false) then
            DBS.Util.Notify(ply, "Vinny already taught you lockpicking.")
            return
        end
        if not ply:CanAfford(fee) then
            DBS.Util.Notify(ply, "Need $" .. string.Comma(fee) .. " for lockpick lessons.")
            return
        end

        ply:AddMoney(-fee)
        ply:SetNWBool("DBS_TrainedLockpick", true)
        ply:Give("weapon_dbs_lockpick")
        DBS.Util.Notify(ply, "Vinny taught you lockpicking for $" .. string.Comma(fee) .. ".")
        DBS.PickpocketTrainer.Open(ply)
        return
    end

    local desiredLevel = GetLevelForCred(DBS.Player.GetCred(ply))
    local trained = ply:GetNWBool("DBS_TrainedPickpocket", false)
    local currentLevel = math.max(1, ply:GetNWInt("DBS_PickpocketSkillLevel", 1))

    if not trained then
        ply:SetNWBool("DBS_TrainedPickpocket", true)
        ply:SetNWInt("DBS_PickpocketSkillLevel", desiredLevel)
        ply:Give("weapon_dbs_pickpocket")
        DBS.Util.Notify(ply, "Vinny taught you pickpocketing. Skill Lv." .. desiredLevel .. ".")
        DBS.PickpocketTrainer.Open(ply)
        return
    end

    if desiredLevel <= currentLevel then
        DBS.Util.Notify(ply, "Raise your CRED first, then come back for advanced lessons.")
        return
    end

    local cost = 300 * (desiredLevel - currentLevel)
    if not ply:CanAfford(cost) then
        DBS.Util.Notify(ply, "Need $" .. string.Comma(cost) .. " for the upgrade.")
        return
    end

    ply:AddMoney(-cost)
    ply:SetNWInt("DBS_PickpocketSkillLevel", desiredLevel)
    DBS.Util.Notify(ply, "Pickpocket upgraded to Lv." .. desiredLevel .. ".")
    DBS.PickpocketTrainer.Open(ply)
end)
