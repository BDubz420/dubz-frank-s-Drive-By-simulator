DBS = DBS or {}
DBS.PickpocketTrainer = DBS.PickpocketTrainer or {}

util.AddNetworkString("DBS_Pickpocket_Open")
util.AddNetworkString("DBS_Pickpocket_Learn")

local PICK_LEVELS = {
    [1] = { cred = 0, cost = 0 },
    [2] = { cred = 1, cost = 350 },
    [3] = { cred = 2, cost = 700 },
    [4] = { cred = 3, cost = 1200 },
    [5] = { cred = 4, cost = 1800 }
}

local LOCK_LEVELS = {
    [1] = { cred = 0, cost = 250 },
    [2] = { cred = 1, cost = 450 },
    [3] = { cred = 2, cost = 800 },
    [4] = { cred = 3, cost = 1250 },
    [5] = { cred = 4, cost = 1850 }
}

local function GetUnlockedLevelByCred(cred, levels)
    local unlocked = 1
    for lvl, req in ipairs(levels) do
        if cred >= (req.cred or 0) then unlocked = lvl end
    end
    return math.Clamp(unlocked, 1, 5)
end

function DBS.PickpocketTrainer.Open(ply)
    if not IsValid(ply) then return end

    local cred = DBS.Player.GetCred(ply)
    local trainedPick = ply:GetNWBool("DBS_TrainedPickpocket", false)
    local trainedLock = ply:GetNWBool("DBS_TrainedLockpick", false)
    local pickLevel = math.Clamp(ply:GetNWInt("DBS_PickpocketSkillLevel", 1), 1, 5)
    local lockLevel = math.Clamp(ply:GetNWInt("DBS_LockpickSkillLevel", 1), 1, 5)

    net.Start("DBS_Pickpocket_Open")
        net.WriteBool(trainedPick)
        net.WriteBool(trainedLock)
        net.WriteUInt(pickLevel, 3)
        net.WriteUInt(lockLevel, 3)
        net.WriteUInt(GetUnlockedLevelByCred(cred, PICK_LEVELS), 3)
        net.WriteUInt(GetUnlockedLevelByCred(cred, LOCK_LEVELS), 3)
        net.WriteUInt(math.Clamp(cred, 0, 63), 6)

        net.WriteUInt(PICK_LEVELS[pickLevel + 1] and PICK_LEVELS[pickLevel + 1].cred or 0, 6)
        net.WriteInt(PICK_LEVELS[pickLevel + 1] and PICK_LEVELS[pickLevel + 1].cost or 0, 32)

        net.WriteUInt(LOCK_LEVELS[lockLevel + 1] and LOCK_LEVELS[lockLevel + 1].cred or 0, 6)
        net.WriteInt(LOCK_LEVELS[lockLevel + 1] and LOCK_LEVELS[lockLevel + 1].cost or 0, 32)
    net.Send(ply)
end

local function SetPickLevel(ply, lvl)
    lvl = math.Clamp(tonumber(lvl) or 1, 1, 5)
    ply:SetNWBool("DBS_TrainedPickpocket", true)
    ply:SetNWInt("DBS_PickpocketSkillLevel", lvl)
    ply:SetPData("dbs_trained_pickpocket", "1")
    ply:SetPData("dbs_pickpocket_lvl", tostring(lvl))
end

local function SetLockLevel(ply, lvl)
    lvl = math.Clamp(tonumber(lvl) or 1, 1, 5)
    ply:SetNWBool("DBS_TrainedLockpick", true)
    ply:SetNWInt("DBS_LockpickSkillLevel", lvl)
    ply:SetPData("dbs_trained_lockpick", "1")
    ply:SetPData("dbs_lockpick_lvl", tostring(lvl))
end

net.Receive("DBS_Pickpocket_Learn", function(_, ply)
    if not IsValid(ply) then return end

    local action = net.ReadString()
    local cred = DBS.Player.GetCred(ply)

    if action == "pickpocket" then
        local current = math.Clamp(ply:GetNWInt("DBS_PickpocketSkillLevel", 1), 1, 5)
        local nextLvl = current + 1

        if not ply:GetNWBool("DBS_TrainedPickpocket", false) then
            SetPickLevel(ply, 1)
            ply:Give("weapon_dbs_pickpocket")
            DBS.Util.Notify(ply, "Vinny taught you pickpocket basics (Lv.1).")
            DBS.PickpocketTrainer.Open(ply)
            return
        end

        if nextLvl > 5 then DBS.Util.Notify(ply, "Pickpocket already max level.") return end

        local req = PICK_LEVELS[nextLvl]
        if cred < req.cred then
            DBS.Util.Notify(ply, "Need CRED " .. req.cred .. " for this upgrade.")
            return
        end
        if not ply:CanAfford(req.cost) then
            DBS.Util.Notify(ply, "Need $" .. string.Comma(req.cost) .. " for this upgrade.")
            return
        end

        ply:AddMoney(-req.cost)
        SetPickLevel(ply, nextLvl)
        DBS.Util.Notify(ply, "Pickpocket upgraded to Lv." .. nextLvl .. " for $" .. string.Comma(req.cost) .. ".")
        DBS.PickpocketTrainer.Open(ply)
        return
    end

    if action == "lockpick" then
        local current = math.Clamp(ply:GetNWInt("DBS_LockpickSkillLevel", 1), 1, 5)
        local nextLvl = current + 1

        if not ply:GetNWBool("DBS_TrainedLockpick", false) then
            local req = LOCK_LEVELS[1]
            if not ply:CanAfford(req.cost) then
                DBS.Util.Notify(ply, "Need $" .. string.Comma(req.cost) .. " for lockpick lessons.")
                return
            end
            ply:AddMoney(-req.cost)
            SetLockLevel(ply, 1)
            ply:Give("weapon_dbs_lockpick")
            DBS.Util.Notify(ply, "Vinny taught you lockpicking (Lv.1) for $" .. string.Comma(req.cost) .. ".")
            DBS.PickpocketTrainer.Open(ply)
            return
        end

        if nextLvl > 5 then DBS.Util.Notify(ply, "Lockpick already max level.") return end
        local req = LOCK_LEVELS[nextLvl]
        if cred < req.cred then
            DBS.Util.Notify(ply, "Need CRED " .. req.cred .. " for this upgrade.")
            return
        end
        if not ply:CanAfford(req.cost) then
            DBS.Util.Notify(ply, "Need $" .. string.Comma(req.cost) .. " for this upgrade.")
            return
        end

        ply:AddMoney(-req.cost)
        SetLockLevel(ply, nextLvl)
        DBS.Util.Notify(ply, "Lockpick upgraded to Lv." .. nextLvl .. " for $" .. string.Comma(req.cost) .. ".")
        DBS.PickpocketTrainer.Open(ply)
    end
end)
