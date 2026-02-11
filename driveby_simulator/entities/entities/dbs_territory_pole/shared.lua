ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Territory Pole"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "OwnerTeam")      -- 0 = neutral
    self:NetworkVar("Int", 1, "State")          -- DBS.Const.TerritoryState
    self:NetworkVar("Float", 0, "DecayEndsAt")  -- owned decay timer
    self:NetworkVar("Float", 1, "ContestEndsAt")
    self:NetworkVar("Int", 2, "CapturingTeam")
    self:NetworkVar("Float", 2, "CaptureEndsAt")
end
