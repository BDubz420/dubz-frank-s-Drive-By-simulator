AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local function FindNearbyEntity(pos, class, radius)
    for _, ent in ipairs(ents.FindInSphere(pos, radius or 110)) do
        if IsValid(ent) and ent:GetClass() == class then return ent end
    end
end

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

    local raw = FindNearbyEntity(self:GetPos(), "dbs_coke_raw", 120)
    if IsValid(raw) then
        raw:Remove()
        self:SetNWInt("DBS_CokeTableQueued", self:GetNWInt("DBS_CokeTableQueued", 0) + 1)

        local dryTime = math.max(10, tonumber((DBS.Config.CokeDryingTable or {}).DryTime) or 25)
        timer.Simple(dryTime, function()
            if not IsValid(self) then return end
            self:SetNWInt("DBS_CokeTableQueued", math.max(0, self:GetNWInt("DBS_CokeTableQueued", 0) - 1))
            self:SetNWInt("DBS_CokeTableDry", self:GetNWInt("DBS_CokeTableDry", 0) + 1)
        end)

        DBS.Util.Notify(activator, "Placed raw coke on drying table.")
        return
    end

    local dry = self:GetNWInt("DBS_CokeTableDry", 0)
    if dry <= 0 then
        DBS.Util.Notify(activator, "No dry coke ready yet.")
        return
    end

    self:SetNWInt("DBS_CokeTableDry", dry - 1)
    local ent = ents.Create("dbs_coke_dry")
    if IsValid(ent) then
        ent:SetPos(self:GetPos() + self:GetForward() * 22 + Vector(0, 0, 20))
        ent:Spawn()
    end

    DBS.Util.Notify(activator, "Spawned dried coke chunk.")
end
