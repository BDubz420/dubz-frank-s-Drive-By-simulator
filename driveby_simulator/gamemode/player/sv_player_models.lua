DBS = DBS or {}
DBS.Config = DBS.Config or {}

local function PickValidModel(models)
    if not istable(models) then return nil end

    local valid = {}
    for _, mdl in ipairs(models) do
        if util.IsValidModel(mdl) then
            valid[#valid + 1] = mdl
        end
    end

    if #valid == 0 then return nil end
    return table.Random(valid)
end

hook.Add("PlayerSpawn", "DBS.ApplyTeamModel", function(ply)
    if not IsValid(ply) then return end
    if not DBS.Config.PlayerModels then return end

    local teamID = ply:Team() or 0
    local model = PickValidModel(DBS.Config.PlayerModels[teamID])

    if not model then
        model = "models/player/group03/male_07.mdl"
    end

    ply:SetModel(model)
end)

hook.Add("PlayerSetModel", "DBS.BlockModelChange", function()
    return true
end)
