DBS.Vehicles = DBS.Vehicles or {}

local function IsScannableVehicle(ent)
    if not IsValid(ent) then return false end
    for _, class in ipairs(DBS.Config.Vehicles.ScanClasses) do
        if ent:GetClass() == class then return true end
    end
    return false
end

hook.Add("InitPostEntity", "DBS.Vehicles.Scan", function()
    for _, ent in ipairs(ents.GetAll()) do
        if IsScannableVehicle(ent) then
            ent:SetNWInt("DBS_OwnerTeam", 0) -- 0 = neutral
        end
    end
end)
