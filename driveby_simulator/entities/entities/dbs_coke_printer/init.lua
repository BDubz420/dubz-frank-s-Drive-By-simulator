AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function FindNearbyEntity(pos, class, radius)
    for _, ent in ipairs(ents.FindInSphere(pos, radius or 110)) do
        if IsValid(ent) and ent:GetClass() == class then return ent end
    end
end

function ENT:Initialize()
    self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetNWInt("DBS_CokeProcessorSupplies", 0)
    self:SetNWInt("DBS_CokeProcessorRaw", 0)

    local cfg = DBS.Config.CokePrinter or {}
    local tick = math.max(8, tonumber(cfg.ProcessInterval) or 20)

    timer.Create("DBS.CokeProcessor." .. self:EntIndex(), tick, 0, function()
        if not IsValid(self) then return end
        local supplies = self:GetNWInt("DBS_CokeProcessorSupplies", 0)
        if supplies <= 0 then return end
        self:SetNWInt("DBS_CokeProcessorSupplies", supplies - 1)
        self:SetNWInt("DBS_CokeProcessorRaw", math.min(20, self:GetNWInt("DBS_CokeProcessorRaw", 0) + 1))
    end)
end

function ENT:OnRemove()
    timer.Remove("DBS.CokeProcessor." .. self:EntIndex())
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local case = FindNearbyEntity(self:GetPos(), "dbs_coke_supply", 110)
    if IsValid(case) then
        local maxSupplies = math.max(1, tonumber((DBS.Config.CokePrinter or {}).MaxSupplies) or 20)
        local supplies = self:GetNWInt("DBS_CokeProcessorSupplies", 0)
        if supplies >= maxSupplies then
            DBS.Util.Notify(activator, "Coke processor supply bay is full.")
            return
        end

        case:Remove()
        self:SetNWInt("DBS_CokeProcessorSupplies", supplies + 1)
        DBS.Util.Notify(activator, "Loaded 1 supply case into processor.")
        return
    end

    local raw = self:GetNWInt("DBS_CokeProcessorRaw", 0)
    if raw <= 0 then
        DBS.Util.Notify(activator, "No raw coke ready. Bring supply case near machine and press E.")
        return
    end

    self:SetNWInt("DBS_CokeProcessorRaw", raw - 1)

    local ent = ents.Create("dbs_coke_raw")
    if IsValid(ent) then
        ent:SetPos(self:GetPos() + self:GetForward() * 24 + Vector(0, 0, 20))
        ent:Spawn()
    end

    DBS.Util.Notify(activator, "Output 1 raw coke chunk.")
end
