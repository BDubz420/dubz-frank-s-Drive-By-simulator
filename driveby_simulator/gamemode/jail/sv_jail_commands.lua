DBS = DBS or {}
DBS.Jail = DBS.Jail or {}

local function SaveJailPositions()
    local dataDir = "dbs"
    local dataFile = dataDir .. "/jail_positions_" .. game.GetMap() .. ".json"

    if not file.IsDir(dataDir, "DATA") then
        file.CreateDir(dataDir)
    end

    file.Write(dataFile, util.TableToJSON(DBS.Config.Spawns.JailPositions or {}, true))
end

local function LoadJailPositions()
    local dataFile = "dbs/jail_positions_" .. game.GetMap() .. ".json"
    if not file.Exists(dataFile, "DATA") then return end

    local parsed = util.JSONToTable(file.Read(dataFile, "DATA") or "")
    if istable(parsed) and #parsed > 0 then
        DBS.Config.Spawns.JailPositions = parsed
    end
end

hook.Add("InitPostEntity", "DBS.Jail.LoadPositions", LoadJailPositions)

concommand.Add("dbs_jail_ok", function(ply)
    if IsValid(ply) and not ply:IsAdmin() then return end
    if IsValid(ply) and not ply.DBS_JailTime then return end
    DBS.Jail.Send(ply)
end)

concommand.Add("dbs_setjailpos", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    DBS.Config.Spawns.JailPositions = {
        { Pos = ply:GetPos(), Ang = ply:EyeAngles() }
    }

    SaveJailPositions()
    DBS.Util.Notify(ply, "Set jail spawn position.")
end)

concommand.Add("dbs_addjailpos", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    DBS.Config.Spawns.JailPositions = DBS.Config.Spawns.JailPositions or {}
    DBS.Config.Spawns.JailPositions[#DBS.Config.Spawns.JailPositions + 1] = {
        Pos = ply:GetPos(),
        Ang = ply:EyeAngles()
    }

    SaveJailPositions()
    DBS.Util.Notify(ply, "Added jail spawn position (#" .. #DBS.Config.Spawns.JailPositions .. ").")
end)
