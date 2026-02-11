AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:KeyValue(key, value)
    if key == "team" then
        local t = string.lower(value or "")
        local teamId = DBS.Const.TeamNames and DBS.Const.TeamNames[t]

        if teamId then
            self:SetDealerTeam(teamId)
        else
            print("[DBS] Eli NPC spawned with invalid team:", value)
        end
    end
end

function ENT:Initialize()
    local teamId = self:GetDealerTeam()

    local model = DBS.Config.DealerModels
        and DBS.Config.DealerModels[teamId]
        or "models/Humans/Group03/male_07.mdl"

    self:SetModel(model)

    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)
    self:SetBloodColor(BLOOD_COLOR_RED)

    self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
    self:SetMaxYawSpeed(90)

    self:SetHealth(100)
end

function ENT:AcceptInput(inputName, activator)
    if inputName ~= "Use" then return end
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if activator:Team() ~= self:GetDealerTeam() then
        DBS.Util.Notify(activator, "This dealer doesn't deal with you.")
        return
    end

    if DBS and DBS.Eli and DBS.Eli.Open then
        DBS.Eli.Open(activator)
    end
end
