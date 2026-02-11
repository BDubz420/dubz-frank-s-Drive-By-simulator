DBS = DBS or {}
DBS.Player = DBS.Player or {}

local function GetSpawnData_Intro()
    local intro = DBS.Config and DBS.Config.Spawns and DBS.Config.Spawns.Intro
    if not intro then return nil end
    return intro.Pos, intro.Ang
end

local function GetSpawnData_HQ(ply)
    local sp = DBS.Config and DBS.Config.Spawns
    if not sp or not sp.HQ then return nil end

    local hq = sp.HQ[ply:Team()]
    if not hq then return nil end

    return hq.Pos, hq.Ang
end

function DBS.Player.SpawnIntro(ply)
    if not IsValid(ply) then return end

    local pos, ang = GetSpawnData_Intro()
    if isvector(pos) then ply:SetPos(pos) end
    if isangle(ang) then ply:SetEyeAngles(ang) end
end

function DBS.Player.SpawnHQ(ply)
    if not IsValid(ply) then return end

    -- If they haven't picked a team yet, intro
    if ply:Team() == TEAM_UNASSIGNED or ply:Team() == 0 then
        return DBS.Player.SpawnIntro(ply)
    end

    local pos, ang = GetSpawnData_HQ(ply)
    if not isvector(pos) then
        -- Fail-safe: intro if HQ not configured
        return DBS.Player.SpawnIntro(ply)
    end

    ply:SetPos(pos)
    if isangle(ang) then ply:SetEyeAngles(ang) end
end

-- ===== CRED =====
function DBS.Player.GetCred(ply)
    return ply:GetNWInt("DBS_Cred", 0)
end

function DBS.Player.SetCred(ply, amount)
    local v = math.max(0, amount)
    ply:SetNWInt("DBS_Cred", v)
    if SERVER then ply:SetPData("dbs_cred", tostring(v)) end
end

function DBS.Player.AddCred(ply, amount)
    DBS.Player.SetCred(ply, DBS.Player.GetCred(ply) + amount)
end

-- ===== MONEY =====
function DBS.Player.GetMoney(ply)
    return ply:GetNWInt("DBS_Money", 0)
end

function DBS.Player.SetMoney(ply, amount)
    ply:SetNWInt("DBS_Money", math.max(0, amount))
end

function DBS.Player.AddMoney(ply, amount)
    DBS.Player.SetMoney(ply, DBS.Player.GetMoney(ply) + amount)
end
