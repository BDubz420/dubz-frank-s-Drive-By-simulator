AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureTable002a.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetNWInt("DBS_CokeTableQueued", 0)
    self:SetNWInt("DBS_CokeTableDry", 0)
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local wet = activator:GetNWInt("DBS_CokeWetBatch", 0)
    if wet > 0 then
        activator:SetNWInt("DBS_CokeWetBatch", wet - 1)
        self:SetNWInt("DBS_CokeTableQueued", self:GetNWInt("DBS_CokeTableQueued", 0) + 1)

        local dryTime = math.max(5, tonumber((DBS.Config.CokeDryingTable or {}).DryTime) or 20)
        timer.Simple(dryTime, function()
            if not IsValid(self) then return end
            self:SetNWInt("DBS_CokeTableQueued", math.max(0, self:GetNWInt("DBS_CokeTableQueued", 0) - 1))
            self:SetNWInt("DBS_CokeTableDry", self:GetNWInt("DBS_CokeTableDry", 0) + 1)
        end)

        DBS.Util.Notify(activator, "Placed wet batch on drying table.")
        return
    end

    local dry = self:GetNWInt("DBS_CokeTableDry", 0)
    if dry <= 0 then
        DBS.Util.Notify(activator, "No dry batches ready.")
        return
    end

    self:SetNWInt("DBS_CokeTableDry", dry - 1)
    activator:SetNWInt("DBS_CokeDryBatch", activator:GetNWInt("DBS_CokeDryBatch", 0) + 1)
    DBS.Util.Notify(activator, "Took 1 dry batch. Use a brick packer to finish it.")
end
