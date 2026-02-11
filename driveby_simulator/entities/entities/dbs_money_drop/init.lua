AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props/cs_assault/money.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
end

function ENT:SetAmount(amount)
    self.Amount = amount
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if not self.Amount or self.Amount <= 0 then return end

    DBS.Player.AddMoney(activator, self.Amount)
    self:Remove()
end
