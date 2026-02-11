ENT.Type = "ai"
ENT.Base = "base_ai"

ENT.PrintName = "Eli"
ENT.Author = "Dubz420"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "DealerTeam")
    self:NetworkVar("Int", 1, "DealerID")
end
