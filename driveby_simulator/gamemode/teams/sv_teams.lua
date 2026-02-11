function DBS.Teams.Register()
    for id, t in pairs(DBS.Teams.Definitions) do
        team.SetUp(id, t.name, t.color, false)
    end
end

hook.Add("Initialize", "DBS.Teams.Register", function()
    DBS.Teams.Register()
end)
