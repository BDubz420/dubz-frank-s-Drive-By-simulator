DBS = DBS or {}
DBS.DAdmin = DBS.DAdmin or { Bans = {} }

util.AddNetworkString("DBS_DAdmin_Open")
util.AddNetworkString("DBS_DAdmin_Action")

local DATA_DIR = "dbs"
local BAN_FILE = DATA_DIR .. "/dadmin_bans.json"

local function SaveBans()
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
    file.Write(BAN_FILE, util.TableToJSON(DBS.DAdmin.Bans, true))
end

local function LoadBans()
    if not file.Exists(BAN_FILE, "DATA") then return end
    local t = util.JSONToTable(file.Read(BAN_FILE, "DATA") or "")
    DBS.DAdmin.Bans = istable(t) and t or {}
end
hook.Add("InitPostEntity", "DBS.DAdmin.Load", LoadBans)

hook.Add("CheckPassword", "DBS.DAdmin.CheckBan", function(steamID64)
    local b = DBS.DAdmin.Bans[steamID64]
    if not b then return end
    if b.untilTime > os.time() then
        return false, "Banned: " .. (b.reason or "No reason")
    end
    DBS.DAdmin.Bans[steamID64] = nil
    SaveBans()
end)

local function OpenMenu(admin)
    local rows = {}
    for _, ply in ipairs(player.GetAll()) do
        rows[#rows + 1] = { Name = ply:Nick(), SID = ply:SteamID64() }
    end

    net.Start("DBS_DAdmin_Open")
        net.WriteTable(rows)
    net.Send(admin)
end

concommand.Add("dbs_admin_menu", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    OpenMenu(ply)
end)

hook.Add("PlayerSay", "DBS.DAdminChat", function(ply, text)
    local msg = string.lower(string.Trim(text or ""))
    if msg == "!dadmin" or msg == "/dadmin" then
        if IsValid(ply) and ply:IsAdmin() then OpenMenu(ply) end
        return ""
    end
end)

net.Receive("DBS_DAdmin_Action", function(_, admin)
    if not IsValid(admin) or not admin:IsAdmin() then return end

    local action = net.ReadString()
    local sid = net.ReadString()

    local target
    for _, p in ipairs(player.GetAll()) do
        if p:SteamID64() == sid then target = p break end
    end

    if action == "freeze" and IsValid(target) then
        target:Freeze(not target:IsFrozen())
        return
    end

    if action == "kick" and IsValid(target) then
        target:Kick("Kicked by Dubz Admin")
        return
    end

    if action == "jail" and IsValid(target) then
        DBS.Jail.SendToJail(target, 2)
        return
    end

    if action == "ban" then
        DBS.DAdmin.Bans[sid] = { reason = "Banned by admin", untilTime = os.time() + (60 * 60) }
        SaveBans()
        if IsValid(target) then target:Kick("Banned by Dubz Admin") end
        return
    end
end)
