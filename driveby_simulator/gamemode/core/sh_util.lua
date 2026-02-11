-- gamemode/core/sh_util.lua
DBS = DBS or {}
DBS.Util = DBS.Util or {}

-- Include helpers (paths are RELATIVE TO gamemode/)
function DBS.Util.IncludeShared(rel)
    if SERVER then AddCSLuaFile(rel) end
    return include(rel)
end

function DBS.Util.IncludeServer(rel)
    if SERVER then
        return include(rel)
    end
end

function DBS.Util.IncludeClient(rel)
    if SERVER then
        AddCSLuaFile(rel)
        return
    end
    return include(rel)
end

-- Team helpers (safe stubs until teams module is loaded)
function DBS.Util.IsPolice(ply)
    if not IsValid(ply) then return false end
    if DBS.Const and DBS.Const.Teams and DBS.Const.Teams.POLICE then
        return ply:Team() == DBS.Const.Teams.POLICE
    end
    return false
end

-- ----------------------------
-- Notification helper
-- ----------------------------

if SERVER then
    util.AddNetworkString("DBS_Notify")
end

function DBS.Util.Notify(ply, msg)
    if not IsValid(ply) then return end

    if SERVER then
        net.Start("DBS_Notify")
            net.WriteString(msg)
        net.Send(ply)
    end
end
