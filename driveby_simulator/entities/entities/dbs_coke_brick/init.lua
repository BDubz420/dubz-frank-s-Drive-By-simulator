AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate025x05.mdl")
    self:SetMaterial("models/shiny")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self.Units = 1
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local add = self.Units or 1
    activator:SetNWInt("DBS_CokeBricks", activator:GetNWInt("DBS_CokeBricks", 0) + add)
    DBS.Util.Notify(activator, "Picked up coke brick (inventory +" .. add .. ").")
    self:Remove()
end
