concommand.Add("dbs_jail_ok", function(ply)
    if not ply.DBS_JailTime then return end
    DBS.Jail.Send(ply)
end)

concommand.Add("dbs_jail_escape", function(ply)
    if not ply.DBS_JailTime then return end

    ply:ChatPrint("Escape attempt coming in Phase 3.5 😉")
    DBS.Jail.Send(ply)
end)
