function GM:PlayerLoadout(ply)
    return true
end

hook.Add("PhysgunPickup", "DBS.PhysgunControl", function(ply)
    if not IsValid(ply) then return false end
    return ply:IsSuperAdmin() or (ply:IsAdmin() and ply:GetNWBool("DBS_SandboxMode", false))
end)

hook.Add("CanTool", "DBS.ToolgunControl", function(ply)
    if not IsValid(ply) then return false end
    return ply:IsSuperAdmin() or (ply:IsAdmin() and ply:GetNWBool("DBS_SandboxMode", false))
end)

hook.Add("PlayerGiveSWEP", "DBS.BlockCameraSWEP", function(ply, class)
    if class ~= "gmod_camera" then return end
    if not IsValid(ply) then return false end

    if ply:IsSuperAdmin() then return true end
    return ply:IsAdmin() and ply:GetNWBool("DBS_SandboxMode", false)
end)
