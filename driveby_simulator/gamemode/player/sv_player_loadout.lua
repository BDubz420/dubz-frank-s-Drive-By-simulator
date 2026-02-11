-- Completely override Sandbox loadout
function GM:PlayerLoadout(ply)
    -- Returning true stops Sandbox from giving default weapons
    return true
end

-- Physgun control
hook.Add("PhysgunPickup", "DBS.PhysgunControl", function(ply)
    return ply:IsSuperAdmin()
end)

-- Toolgun control
hook.Add("CanTool", "DBS.ToolgunControl", function(ply)
    return ply:IsSuperAdmin()
end)

-- Camera control (sandbox camera)
hook.Add("PlayerGiveSWEP", "DBS.BlockCameraSWEP", function(ply, class)
    if class == "gmod_camera" and not ply:IsSuperAdmin() then
        return false
    end
end)
