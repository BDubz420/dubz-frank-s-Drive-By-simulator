AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    local mdl = DBS.Config and DBS.Config.NPC and DBS.Config.NPC.Models and DBS.Config.NPC.Models.Judge
    self:SetModel(mdl or "models/Humans/Group03/male_09.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:DropToFloor()
end
