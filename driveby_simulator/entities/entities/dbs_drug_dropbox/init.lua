AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    local mdl = DBS.Config and DBS.Config.Drugs and DBS.Config.Drugs.DropboxModel
    self:SetModel(mdl or "models/props_vents/vent_medium_grill002.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if DBS.DrugDealer and DBS.DrugDealer.TryDeliver then DBS.DrugDealer.TryDeliver(activator, self) end
end
