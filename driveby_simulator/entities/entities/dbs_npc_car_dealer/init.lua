AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    local mdl = DBS.Config and DBS.Config.NPC and DBS.Config.NPC.Models and DBS.Config.NPC.Models.CarDealer
    self:SetModel(mdl or "models/Humans/Group03/male_06.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:DropToFloor()
end

function ENT:AcceptInput(name, activator)
    if name ~= "Use" then return end
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if DBS.CarMarket and DBS.CarMarket.Open then DBS.CarMarket.Open(activator) end
end
