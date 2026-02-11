AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x05x025.mdl")
    self:SetMaterial("models/props_c17/FurnitureMetal001a")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local dry = activator:GetNWInt("DBS_CokeDryBatch", 0)
    if dry <= 0 then
        DBS.Util.Notify(activator, "You need a dry batch first.")
        return
    end

    activator:SetNWInt("DBS_CokeDryBatch", dry - 1)

    local brick = ents.Create("dbs_coke_brick")
    if IsValid(brick) then
        brick:SetPos(self:GetPos() + self:GetForward() * 20 + Vector(0, 0, 18))
        brick:Spawn()
    end

    DBS.Util.Notify(activator, "Packed 1 coke brick.")
end
