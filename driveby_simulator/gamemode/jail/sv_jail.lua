DBS = DBS or {}
DBS.Jail = DBS.Jail or {}

function DBS.Jail.Send(ply)
    if not IsValid(ply) then return end
    if not ply.DBS_JailTime or ply.DBS_JailTime <= 0 then return end

    -- Move to jail spawn
    if DBS.Config.Spawns and DBS.Config.Spawns.Jail then
        ply:SetPos(DBS.Config.Spawns.Jail.Pos)
        ply:SetEyeAngles(DBS.Config.Spawns.Jail.Ang or Angle(0,0,0))
    end

    ply:Freeze(true)

    timer.Create("DBS_Jail_" .. ply:SteamID64(), 1, ply.DBS_JailTime, function()
        if not IsValid(ply) then return end

        ply.DBS_JailTime = ply.DBS_JailTime - 1

        if ply.DBS_JailTime <= 0 then
            DBS.Jail.Release(ply)
        end
    end)
end

function DBS.Jail.Release(ply)
    timer.Remove("DBS_Jail_" .. ply:SteamID64())

    ply:Freeze(false)
    ply.DBS_JailTime = nil

    ply:ChatPrint("You are free.")

    DBS.Player.SpawnHQ(ply)
end
