AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/consolebox01a.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self.Stored = 0

    local cfg = DBS.Config.Printer or {}
    timer.Create("DBS.Printer." .. self:EntIndex(), cfg.PrintInterval or 8, 0, function()
        if not IsValid(self) then return end
        self.Stored = math.min((cfg.MaxStored or 3000), self.Stored + (cfg.PrintAmount or 35))
    end)
end

function ENT:OnRemove()
    timer.Remove("DBS.Printer." .. self:EntIndex())
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if self.Stored <= 0 then return end

    activator:AddMoney(self.Stored)
    DBS.Util.Notify(activator, "Collected $" .. string.Comma(self.Stored) .. " from printer.")
    self.Stored = 0
end
