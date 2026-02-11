AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/garbage_bag001a.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self.Units = 5
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local add = self.Units or 5
    activator:SetNWInt("DBS_Drugs", activator:GetNWInt("DBS_Drugs", 0) + add)
    DBS.Util.Notify(activator, "Picked up coke brick (+" .. add .. " drugs).")
    self:Remove()
end
