DBS = DBS or {}
DBS.MOTD = DBS.MOTD or {}

util.AddNetworkString("DBS_MOTD_Show")

local DATA_DIR = "dbs"
local DATA_FILE = DATA_DIR .. "/motd_seen_" .. game.GetMap() .. ".json"
local seen = {}

local function LoadSeen()
    if not file.Exists(DATA_FILE, "DATA") then return end
    local parsed = util.JSONToTable(file.Read(DATA_FILE, "DATA") or "")
    if istable(parsed) then seen = parsed end
end

local function SaveSeen()
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
    file.Write(DATA_FILE, util.TableToJSON(seen, true))
end

hook.Add("InitPostEntity", "DBS.MOTD.Load", LoadSeen)

hook.Add("PlayerInitialSpawn", "DBS.MOTD.ShowFirstJoin", function(ply)
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        local sid = ply:SteamID64()
        if sid == "" then return end
        if seen[sid] then return end

        seen[sid] = true
        SaveSeen()

        net.Start("DBS_MOTD_Show")
        net.Send(ply)
    end)
end)
