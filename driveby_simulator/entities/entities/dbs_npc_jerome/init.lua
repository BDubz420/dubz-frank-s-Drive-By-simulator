AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    local mdl = DBS.Config and DBS.Config.NPC and DBS.Config.NPC.Models and DBS.Config.NPC.Models.TeamSelector
    self:SetModel(mdl or "models/Humans/Group03/male_07.mdl")
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:DropToFloor()
end

function ENT:AcceptInput(name, activator)
    if name ~= "Use" then return end
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Only unassigned players can talk to Jerome
    if activator:Team() ~= TEAM_UNASSIGNED and activator:Team() ~= 0 then
        activator:ChatPrint("You already chose a side.")
        return
    end

    DBS.Jerome.OpenMenu(activator)
end
