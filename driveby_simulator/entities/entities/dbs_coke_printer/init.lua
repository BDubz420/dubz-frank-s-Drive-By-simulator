AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetNWInt("DBS_CokePrinterStored", 0)

    timer.Create("DBS.CokePrinter." .. self:EntIndex(), 18, 0, function()
        if not IsValid(self) then return end

        if math.random() <= 0.35 then
            self:SetNWInt("DBS_CokePrinterStored", math.min(10, self:GetNWInt("DBS_CokePrinterStored", 0) + 1))
        end
    end)
end

function ENT:OnRemove()
    timer.Remove("DBS.CokePrinter." .. self:EntIndex())
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local stored = self:GetNWInt("DBS_CokePrinterStored", 0)
    if stored <= 0 then
        DBS.Util.Notify(activator, "No coke bricks ready yet.")
        return
    end

    self:SetNWInt("DBS_CokePrinterStored", stored - 1)

    local brick = ents.Create("dbs_coke_brick")
    if IsValid(brick) then
        brick:SetPos(self:GetPos() + self:GetForward() * 22 + Vector(0, 0, 18))
        brick:Spawn()
    end

    DBS.Util.Notify(activator, "Dispensed 1 coke brick.")
end
