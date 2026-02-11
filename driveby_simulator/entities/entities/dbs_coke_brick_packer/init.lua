AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function FindNearbyEntity(pos, class, radius)
    for _, ent in ipairs(ents.FindInSphere(pos, radius or 110)) do
        if IsValid(ent) and ent:GetClass() == class then return ent end
    end
end

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever_cart.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local dry = FindNearbyEntity(self:GetPos(), "dbs_coke_dry", 120)
    if not IsValid(dry) then
        DBS.Util.Notify(activator, "Bring dried coke near the brick packer first.")
        return
    end

    dry:Remove()

    local brick = ents.Create("dbs_coke_brick")
    if IsValid(brick) then
        brick:SetPos(self:GetPos() + self:GetForward() * 28 + Vector(0, 0, 20))
        brick:Spawn()
    end

    DBS.Util.Notify(activator, "Packed 1 coke brick.")
end
