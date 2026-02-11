AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/consolebox01a.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.Stored = 0

    local cfg = DBS.Config.Printer or {}
    local interval = math.max(2, cfg.PrintInterval or 8)

    self:SetNWInt("DBS_PrinterStored", 0)
    self:SetNWInt("DBS_PrinterMax", cfg.MaxStored or 3000)
    self:SetNWFloat("DBS_PrinterNextTick", CurTime() + interval)

    timer.Create("DBS.Printer." .. self:EntIndex(), interval, 0, function()
        if not IsValid(self) then return end

        local maxStored = cfg.MaxStored or 3000
        self.Stored = math.min(maxStored, self.Stored + (cfg.PrintAmount or 35))
        self:SetNWInt("DBS_PrinterStored", self.Stored)
        self:SetNWInt("DBS_PrinterMax", maxStored)
        self:SetNWFloat("DBS_PrinterNextTick", CurTime() + interval)
    end)
end

function ENT:OnRemove()
    timer.Remove("DBS.Printer." .. self:EntIndex())
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if self.Stored <= 0 then
        DBS.Util.Notify(activator, "Printer is empty right now.")
        return
    end

    activator:AddMoney(self.Stored)
    DBS.Util.Notify(activator, "Collected $" .. string.Comma(self.Stored) .. " from printer.")
    self.Stored = 0
    self:SetNWInt("DBS_PrinterStored", 0)
end
