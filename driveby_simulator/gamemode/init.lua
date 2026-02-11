-- gamemode/init.lua
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Networking early (if you have these files; otherwise comment out)
if file.Exists("networking/sh_net.lua", "LUA") then
    DBS.Util.IncludeShared("networking/sh_net.lua")
end
if file.Exists("networking/sv_net.lua", "LUA") then
    DBS.Util.IncludeServer("networking/sv_net.lua")
end

-- Player core must load BEFORE spawn/death server files
DBS.Util.IncludeShared("player/sh_player.lua")
DBS.Util.IncludeServer("player/sv_player_spawn.lua")
DBS.Util.IncludeServer("player/sv_team_select.lua")
DBS.Util.IncludeServer("npc/sv_npc_jerome.lua")
DBS.Util.IncludeServer("map/sv_map_ents.lua")
DBS.Util.IncludeServer("map/sv_permaprops.lua")
DBS.Util.IncludeServer("doors/sv_doors.lua")
DBS.Util.IncludeServer("courthouse/sv_court.lua")
DBS.Util.IncludeServer("jail/sv_jail.lua")
DBS.Util.IncludeServer("jail/sv_jail_commands.lua")
DBS.Util.IncludeServer("player/sv_player_loadout.lua")
DBS.Util.IncludeServer("npc/sv_npc_eli.lua")
DBS.Util.IncludeServer("npc/sv_npc_pickpocket.lua")
DBS.Util.IncludeServer("vehicles/sv_car_market.lua")
DBS.Util.IncludeServer("drugs/sv_drug_dealer.lua")
DBS.Util.IncludeServer("admin/sv_dadmin.lua")
DBS.Util.IncludeServer("ui/sv_motd.lua")
DBS.Util.IncludeServer("player/sh_player_rules.lua")
DBS.Util.IncludeServer("player/sv_player_models.lua")
DBS.Util.IncludeServer("player/sv_drop_weapon.lua")
DBS.Util.IncludeServer("player/sv_vulnerability.lua")
DBS.Util.IncludeServer("police/sv_police_arrest.lua")

AddCSLuaFile("core/cl_util.lua")
AddCSLuaFile("territories/cl_territory_render.lua")
AddCSLuaFile("core/sv_debug_commands.lua")
include("core/sv_debug_commands.lua")

-- Optional: include other modules only if they exist (prevents hard boot failures)
local opt_sv = {
    "economy/sv_money.lua",
    "economy/sv_drops.lua",
    "player/sv_player_death.lua",
    "hooks/sv_hooks.lua",
    "vehicles/sv_vehicle_spawn.lua",
    "vehicles/sv_vehicle_conversion.lua",
    "vehicles/sv_vehicle_lockpick.lua",
    "court/courthouse/sv_court_sentencing.lua",
}

for _, rel in ipairs(opt_sv) do
    if file.Exists(rel, "LUA") then
        DBS.Util.IncludeServer(rel)
    end
end
