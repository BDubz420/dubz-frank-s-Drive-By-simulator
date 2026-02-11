DeriveGamemode("sandbox")

GM.Name = "DriveBy Simulator"
GM.Author = "Dubz & Frank"

DBS = DBS or {}
DBS.Name = "DriveBy Simulator"
DBS.Version = "0.2.0"

-- IMPORTANT: make sure clients receive util
if SERVER then
    AddCSLuaFile("core/sh_util.lua")
end
include("core/sh_util.lua")
include("core/cl_util.lua")

-- Now util exists, so these will AddCSLuaFile correctly
DBS.Util.IncludeShared("core/sh_constants.lua")
DBS.Util.IncludeShared("core/sh_config.lua")
DBS.Util.IncludeShared("networking/sh_net.lua")
DBS.Util.IncludeShared("teams/sh_teams.lua")
DBS.Util.IncludeShared("player/sh_player.lua")
DBS.Util.IncludeShared("economy/sh_money.lua")
DBS.Util.IncludeShared("inventory/sh_inventory.lua")
DBS.Util.IncludeShared("territories/sh_territories.lua")
DBS.Util.IncludeShared("courthouse/sh_court.lua")
DBS.Util.IncludeShared("jail/sh_jail.lua")
DBS.Util.IncludeShared("map/sh_map_ents.lua")
DBS.Util.IncludeClient("npc/cl_jerome_ui.lua")
DBS.Util.IncludeShared("courthouse/sh_court.lua")
DBS.Util.IncludeClient("npc/cl_npc_eli.lua")
DBS.Util.IncludeClient("territories/cl_territory_render.lua")
DBS.Util.IncludeClient("ui/sh_player_hud.lua")

AddCSLuaFile("player/sh_player_rules.lua")
include("player/sh_player_rules.lua")

AddCSLuaFile("ui/sh_scoreboard.lua")
include("ui/sh_scoreboard.lua")
