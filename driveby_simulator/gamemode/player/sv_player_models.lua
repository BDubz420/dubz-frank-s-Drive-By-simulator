DBS = DBS or {}
DBS.Config = DBS.Config or {}

local function BuildValidModelPool(models)
    local valid = {}
    if not istable(models) then return valid end

    for _, mdl in ipairs(models) do
        if util.IsValidModel(mdl) then
            valid[#valid + 1] = mdl
        end
    end

    return valid
end

local function PickAnyValidModel()
    local pool = {}

    for _, models in pairs(DBS.Config.PlayerModels or {}) do
        for _, mdl in ipairs(BuildValidModelPool(models)) do
            pool[#pool + 1] = mdl
        end
    end

    if #pool == 0 then
        return "models/player/group03/male_07.mdl"
    end

    return table.Random(pool)
end

hook.Add("PlayerSpawn", "DBS.ApplyTeamModel", function(ply)
    if not IsValid(ply) then return end

    local teamID = ply:Team() or 0
    local teamModels = BuildValidModelPool(DBS.Config.PlayerModels and DBS.Config.PlayerModels[teamID])

    local model
    if #teamModels > 0 then
        model = table.Random(teamModels)
    else
        model = PickAnyValidModel()
    end

    ply:SetModel(model)
end)

hook.Add("PlayerSetModel", "DBS.BlockModelChange", function()
    return true
end)
