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

    self:SetNWInt("DBS_CokeProcessorSupplies", 0)
    self:SetNWInt("DBS_CokeProcessorWet", 0)

    local cfg = DBS.Config.CokePrinter or {}
    local tick = math.max(6, tonumber(cfg.ProcessInterval) or 18)

    timer.Create("DBS.CokeProcessor." .. self:EntIndex(), tick, 0, function()
        if not IsValid(self) then return end

        local supplies = self:GetNWInt("DBS_CokeProcessorSupplies", 0)
        if supplies <= 0 then return end

        self:SetNWInt("DBS_CokeProcessorSupplies", math.max(0, supplies - 1))
        self:SetNWInt("DBS_CokeProcessorWet", math.min(20, self:GetNWInt("DBS_CokeProcessorWet", 0) + 1))
    end)
end

function ENT:OnRemove()
    timer.Remove("DBS.CokeProcessor." .. self:EntIndex())
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local maxSupplies = math.max(1, tonumber((DBS.Config.CokePrinter or {}).MaxSupplies) or 20)
    local supplies = self:GetNWInt("DBS_CokeProcessorSupplies", 0)

    if activator:KeyDown(IN_SPEED) then
        if supplies >= maxSupplies then
            DBS.Util.Notify(activator, "Coke processor supply bay is full.")
            return
        end

        local stash = activator:GetNWInt("DBS_Drugs", 0)
        if stash <= 0 then
            DBS.Util.Notify(activator, "You need drug supplies. Hold sprint + use to load 1.")
            return
        end

        activator:SetNWInt("DBS_Drugs", stash - 1)
        self:SetNWInt("DBS_CokeProcessorSupplies", supplies + 1)
        DBS.Util.Notify(activator, "Loaded 1 supply into coke processor.")
        return
    end

    local wet = self:GetNWInt("DBS_CokeProcessorWet", 0)
    if wet <= 0 then
        DBS.Util.Notify(activator, "No wet coke ready yet. Hold sprint + use to add supplies.")
        return
    end

    self:SetNWInt("DBS_CokeProcessorWet", wet - 1)
    activator:SetNWInt("DBS_CokeWetBatch", activator:GetNWInt("DBS_CokeWetBatch", 0) + 1)
    DBS.Util.Notify(activator, "Took 1 wet coke batch. Bring it to a drying table.")
end
