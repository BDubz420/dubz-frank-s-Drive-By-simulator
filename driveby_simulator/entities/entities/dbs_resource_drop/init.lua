AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_junk/garbage_bag001a.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
end

function ENT:SetDrop(kind, amount)
    self.DropKind = kind or "supplies"
    self.DropAmount = math.max(1, math.floor(tonumber(amount) or 1))
    if self.DropKind == "supplies" then
        self:SetColor(Color(210, 240, 120))
    elseif self.DropKind == "drugs" then
        self:SetColor(Color(170, 190, 255))
    end
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    local amt = math.max(1, tonumber(self.DropAmount) or 1)
    local kind = self.DropKind or "supplies"

    if kind == "supplies" then
        activator:SetNWInt("DBS_Supplies", activator:GetNWInt("DBS_Supplies", 0) + amt)
    elseif kind == "drugs" then
        activator:SetNWInt("DBS_Drugs", activator:GetNWInt("DBS_Drugs", 0) + amt)
    end

    DBS.Util.Notify(activator, "Picked up " .. amt .. " " .. kind .. ".")
    self:Remove()
end
