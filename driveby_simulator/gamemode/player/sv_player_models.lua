DBS = DBS or {}
DBS.Config = DBS.Config or {}

hook.Add("PlayerSpawn", "DBS.ApplyTeamModel", function(ply)
    if not IsValid(ply) then return end
    if not DBS.Config.PlayerModels then return end

    local teamID = ply:Team() or 0
    local models = DBS.Config.PlayerModels[teamID]
    if not istable(models) or #models == 0 then return end

    ply:SetModel(table.Random(models))
end)

-- Block ALL external model changes (Q menu, ULX, context menu, etc)
hook.Add("PlayerSetModel", "DBS.BlockModelChange", function()
    return true
end)