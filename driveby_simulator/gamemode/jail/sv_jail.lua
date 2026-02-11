DBS = DBS or {}
DBS.Jail = DBS.Jail or {}

local function GetJailSpawn()
    local list = DBS.Config.Spawns and DBS.Config.Spawns.JailPositions
    if istable(list) and #list > 0 then
        return table.Random(list)
    end

    if DBS.Config.Spawns and DBS.Config.Spawns.Jail then
        return { Pos = DBS.Config.Spawns.Jail.Pos, Ang = DBS.Config.Spawns.Jail.Ang or Angle(0, 0, 0) }
    end

    return nil
end

function DBS.Jail.Send(ply)
    if not IsValid(ply) then return end
    if not ply.DBS_JailTime or ply.DBS_JailTime <= 0 then return end

    local spawn = GetJailSpawn()
    if spawn and spawn.Pos then
        ply:SetPos(spawn.Pos)
        ply:SetEyeAngles(spawn.Ang or Angle(0, 0, 0))
    end

    ply:Freeze(true)

    timer.Remove("DBS_Jail_" .. ply:SteamID64())
    timer.Create("DBS_Jail_" .. ply:SteamID64(), 1, ply.DBS_JailTime, function()
        if not IsValid(ply) then return end

        ply.DBS_JailTime = ply.DBS_JailTime - 1
        if ply.DBS_JailTime <= 0 then
            DBS.Jail.Release(ply)
        end
    end)
end

function DBS.Jail.SendToJail(ply, minutes)
    if not IsValid(ply) then return end

    ply.DBS_JailTime = math.max(1, math.floor(minutes * 60))
    DBS.Jail.Send(ply)
end

function DBS.Jail.Release(ply)
    timer.Remove("DBS_Jail_" .. ply:SteamID64())

    ply:Freeze(false)
    ply.DBS_JailTime = nil

    ply:ChatPrint("You are free.")

    DBS.Player.SpawnHQ(ply)
end
