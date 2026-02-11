AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local FLAG_MODEL = "models/squad/sf_plates/sf_plate3x4.mdl"

local TEAM_COLORS = {
    [0] = Color(255, 255, 255), -- Neutral (debug white)
    [DBS.Const.Teams.RED]    = Color(220, 60, 60),
    [DBS.Const.Teams.BLUE]   = Color(60, 120, 220),
    [DBS.Const.Teams.POLICE] = Color(80, 160, 220)
}

-- =========================
-- Helpers
-- =========================
local function GetPlayersInRadius(pos, radius)
    local found = {}
    local r2 = radius * radius

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:GetPos():DistToSqr(pos) <= r2 then
            found[#found + 1] = ply
        end
    end

    return found
end

local function HasEnemyInRadius(ent, teamId)
    local radius = DBS.Config.TerritoryPole.Radius
    for _, ply in ipairs(GetPlayersInRadius(ent:GetPos(), radius)) do
        if ply:Team() ~= 0 and ply:Team() ~= teamId then
            return true
        end
    end
    return false
end

function ENT:IsPlayerInCaptureRange(ply)
    if not IsValid(ply) or not ply:Alive() then return false end
    local r = DBS.Config.TerritoryPole.Radius
    return ply:GetPos():DistToSqr(self:GetPos()) <= (r * r)
end

function ENT:GetPlayersInCaptureRange()
    local t = {}
    local r = DBS.Config.TerritoryPole.Radius
    local r2 = r * r
    local pos = self:GetPos()

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and ply:GetPos():DistToSqr(pos) <= r2 then
            t[#t + 1] = ply
        end
    end

    return t
end

local function NotifyOne(ply, msg)
    if not IsValid(ply) then return end
    net.Start(DBS.Net.Notify)
        net.WriteString(msg)
    net.Send(ply)
end

local function NotifyTeam(teamId, msg)
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Team() == teamId then
            NotifyOne(ply, msg)
        end
    end
end

-- =========================
-- Entity
-- =========================
function ENT:Initialize()
    self:SetModel("models/props_c17/signpole001.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:EnableMotion(false) end

    self:SetOwnerTeam(0)
    self:SetState(DBS.Const.TerritoryState.NEUTRAL)

    self:SetDecayEndsAt(0)
    self:SetContestEndsAt(0)

    self:SetCapturingTeam(0)
    self:SetCaptureEndsAt(0)
            self:SetNWFloat("DBS_CaptureStart", 0)

    self.NoMoneyBlock = {}

    -- =========================
    -- Territory Flag (Child)
    -- =========================
    local flag = ents.Create("prop_physics")
    if IsValid(flag) then
        flag:SetModel(FLAG_MODEL)
        flag:Spawn()
        flag:Activate()

        flag:SetParent(self)
        flag:SetLocalPos(Vector(0, 0.5, 73))
        flag:SetLocalAngles(Angle(0, 0, 90))

        flag:SetMoveType(MOVETYPE_NONE)
        flag:SetSolid(SOLID_NONE)
        flag:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

        flag:SetRenderMode(RENDERMODE_TRANSCOLOR)
        flag:SetMaterial("models/shiny") -- if this doesn't show, swap to "models/debug/debugwhite"
        flag:SetColor(TEAM_COLORS[0])

        self.Flag = flag
    end
end

function ENT:UpdateFlagColor()
    if not IsValid(self.Flag) then return end

    local teamID = self:GetOwnerTeam()
    local col = TEAM_COLORS[teamID] or TEAM_COLORS[0]
    self.Flag:SetColor(col)
end

-- We are not using "Use" anymore for capture
function ENT:Use()
    return
end

function ENT:Think()
    local now = CurTime()

    local owner = self:GetOwnerTeam()
    local state = self:GetState()

    local capMin = (DBS.Config.Territory and DBS.Config.Territory.CaptureTimeMin) or 60
    local capMax = (DBS.Config.Territory and DBS.Config.Territory.CaptureTimeMax) or capMin

    local inRange = self:GetPlayersInCaptureRange()
    local inRangeMap = {}
    for _, ply in ipairs(inRange) do
        inRangeMap[ply:SteamID64()] = true
    end

    for sid in pairs(self.NoMoneyBlock or {}) do
        if not inRangeMap[sid] then
            self.NoMoneyBlock[sid] = nil
        end
    end

    -- =========================
    -- Auto-start capture (NEUTRAL only)
    -- =========================
    if owner == 0 and self:GetCapturingTeam() == 0 then
        local capturer
        for _, ply in ipairs(inRange) do
            local sid = ply:SteamID64()
            if ply:Team() ~= 0 and not DBS.Util.IsPolice(ply) and not (self.NoMoneyBlock and self.NoMoneyBlock[sid]) then
                capturer = ply
                break
            end
        end

        if IsValid(capturer) then
            local cost = DBS.Config.Territory.CaptureCost or 5000
            if not capturer:CanAfford(cost) then
                NotifyOne(capturer, ("You need $%s to start claiming this territory."):format(string.Comma(cost)))
                self.NoMoneyBlock = self.NoMoneyBlock or {}
                self.NoMoneyBlock[capturer:SteamID64()] = true
                capturer:SetNWFloat("DBS_TerritoryNoMoneyUntil", CurTime() + 4)
                capturer:SetNWInt("DBS_TerritoryNoMoneyCost", cost)
                self:NextThink(now + 1)
                return true
            end

            local captureTime = math.Rand(capMin, math.max(capMin, capMax))
            self:SetCapturingTeam(capturer:Team())
            self:SetCaptureEndsAt(now + captureTime)
            self:SetNWFloat("DBS_CaptureStart", now)

            -- Universal world announcement ONLY for unclaimed territories
            net.Start(DBS.Net.Notify)
                net.WriteString("A neutral territory is being claimed!")
            net.Broadcast()
        end
    end

    -- =========================
    -- Cancel capture if capturers leave
    -- =========================
    local capTeam = self:GetCapturingTeam()
    if capTeam ~= 0 then
        local stillHere = false

        for _, ply in ipairs(self:GetPlayersInCaptureRange()) do
            if ply:Team() == capTeam then
                stillHere = true
                break
            end
        end

        if not stillHere then
            self:SetCapturingTeam(0)
            self:SetCaptureEndsAt(0)
            self:SetNWFloat("DBS_CaptureStart", 0)
        end
    end

    -- =========================
    -- Decay owned -> neutral
    -- =========================
    if owner ~= 0 and self:GetDecayEndsAt() > 0 and now >= self:GetDecayEndsAt() then
        self:SetOwnerTeam(0)
        self:SetState(DBS.Const.TerritoryState.NEUTRAL)
        self:SetDecayEndsAt(0)
        self:SetContestEndsAt(0)
        self:UpdateFlagColor()
    end

    -- =========================
    -- Contested logic (enemy presence on owned)
    -- =========================
    if owner ~= 0 then
        if HasEnemyInRadius(self, owner) then
            if state ~= DBS.Const.TerritoryState.CONTESTED then
                self:SetState(DBS.Const.TerritoryState.CONTESTED)
                self:SetContestEndsAt(now + DBS.Config.TerritoryPole.ContestNeutralizeTime)
            end
        else
            if state == DBS.Const.TerritoryState.CONTESTED then
                self:SetState(DBS.Const.TerritoryState.OWNED)
                self:SetContestEndsAt(0)
            end
        end

        -- contested timer completes -> neutral
        if state == DBS.Const.TerritoryState.CONTESTED and self:GetContestEndsAt() > 0 and now >= self:GetContestEndsAt() then
            self:SetOwnerTeam(0)
            self:SetState(DBS.Const.TerritoryState.NEUTRAL)
            self:SetDecayEndsAt(0)
            self:SetContestEndsAt(0)
            self:UpdateFlagColor()
        end
    end

    -- =========================
    -- Capture completion
    -- =========================
    capTeam = self:GetCapturingTeam()
    if capTeam ~= 0 and self:GetCaptureEndsAt() > 0 and now >= self:GetCaptureEndsAt() then
        -- Must still have someone in zone at completion
        local claimant
        for _, ply in ipairs(self:GetPlayersInCaptureRange()) do
            if ply:Team() == capTeam and not DBS.Util.IsPolice(ply) then
                claimant = ply
                break
            end
        end

        if not IsValid(claimant) then
            -- Nobody there at the final moment -> cancel
            self:SetCapturingTeam(0)
            self:SetCaptureEndsAt(0)
            self:SetNWFloat("DBS_CaptureStart", 0)
            self:NextThink(now + 1)
            return true
        end

        local prevOwner = owner
        local enemyOwned = (prevOwner ~= 0 and prevOwner ~= capTeam)

        -- If your config wants enemy presence to cancel at last second
        if DBS.Config.TerritoryPole.CaptureCancelOnEnemy and HasEnemyInRadius(self, capTeam) then
            self:SetCapturingTeam(0)
            self:SetCaptureEndsAt(0)
            self:SetNWFloat("DBS_CaptureStart", 0)
            self:NextThink(now + 1)
            return true
        end

        -- Cost (only for gangs)
        local cost = DBS.Config.Territory.CaptureCost or 5000
        if not claimant:CanAfford(cost) then
            NotifyOne(claimant, ("Not enough money to claim ($%s). Leave and return to retry."):format(cost))
            self.NoMoneyBlock = self.NoMoneyBlock or {}
            self.NoMoneyBlock[claimant:SteamID64()] = true
            claimant:SetNWFloat("DBS_TerritoryNoMoneyUntil", CurTime() + 4)
            claimant:SetNWInt("DBS_TerritoryNoMoneyCost", cost)
            self:SetCapturingTeam(0)
            self:SetCaptureEndsAt(0)
            self:SetNWFloat("DBS_CaptureStart", 0)
            self:NextThink(now + 1)
            return true
        end

        claimant:AddMoney(-cost)

        -- Apply ownership
        self:SetCapturingTeam(0)
        self:SetCaptureEndsAt(0)
        self:SetNWFloat("DBS_CaptureStart", 0)
        self:SetOwnerTeam(capTeam)
        self:SetState(DBS.Const.TerritoryState.OWNED)
        self:SetDecayEndsAt(now + (DBS.Config.Territory.DecayTime or 300))
        self:SetContestEndsAt(0)
        self:UpdateFlagColor()

        -- Cred bonus for stealing
        if enemyOwned then
            claimant:AddCred(1)
        end

        -- =========================
        -- Notifications requested:
        -- - Unclaimed: already did global announcement on capture start
        -- - If owned: notify target gang + capturer gang + claimant
        -- =========================
        if prevOwner ~= 0 and prevOwner ~= capTeam then
            -- Target (previous owner gang)
            NotifyTeam(prevOwner, "One of your territories has been taken!")

            -- Capturer's gang (everyone on their team)
            NotifyTeam(capTeam, "Your gang has captured an enemy territory!")

            -- Capturing player (personal)
            NotifyOne(claimant, enemyOwned and "You captured enemy territory (+1 CRED)." or "You captured a territory.")
        else
            -- Neutral claim completion (no target gang)
            NotifyTeam(capTeam, "Your gang has claimed a neutral territory!")
            NotifyOne(claimant, "Territory claimed.")
        end

        local bonusChance = 0.35
        if math.Rand(0, 1) <= bonusChance and DBS.CarMarket and DBS.CarMarket.TrySpawnBonusCarFarFromPlayers then
            if DBS.CarMarket.TrySpawnBonusCarFarFromPlayers() then
                NotifyTeam(capTeam, "Bonus: a car has spawned somewhere in the city.")
            end
        end
    end

    self:NextThink(now + 1)
    return true
end



if SERVER then
    local function GetPlayersInTerritoryRing(pole, teamID)
        local list = {}
        local radius = (DBS.Config and DBS.Config.TerritoryPole and DBS.Config.TerritoryPole.Radius) or 300
        local radiusSqr = radius * radius

        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or not ply:Alive() then continue end
            if ply:Team() ~= teamID then continue end
            if ply:GetPos():DistToSqr(pole:GetPos()) > radiusSqr then continue end
            list[#list + 1] = ply
        end

        return list
    end

    timer.Create("DBS.TerritoryPassiveIncome", 45, 0, function()
        local poles = ents.FindByClass("dbs_territory_pole")
        if #poles == 0 then return end

        local teamPool = {}
        local holderBonus = {}

        local basePerPole = 80
        local ringBonus = 60

        for _, pole in ipairs(poles) do
            local owner = pole:GetOwnerTeam()
            if not owner or owner == 0 then continue end

            teamPool[owner] = (teamPool[owner] or 0) + basePerPole

            local inRing = GetPlayersInTerritoryRing(pole, owner)
            if #inRing > 0 then
                local holder = table.Random(inRing)
                if IsValid(holder) then
                    holderBonus[holder] = (holderBonus[holder] or 0) + ringBonus
                end
            end
        end

        for teamID, pool in pairs(teamPool) do
            local members = {}
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:Alive() and ply:Team() == teamID then
                    members[#members + 1] = ply
                end
            end

            if #members > 0 and pool > 0 then
                local split = math.max(1, math.floor(pool / #members))
                for _, ply in ipairs(members) do
                    ply:AddMoney(split)
                    local msg = "Territory share: $" .. string.Comma(split)
                    if holderBonus[ply] then
                        ply:AddMoney(holderBonus[ply])
                        msg = msg .. " + ring bonus $" .. string.Comma(holderBonus[ply])
                    end
                    DBS.Util.Notify(ply, msg .. ".")
                    DBS.Util.Notify(ply, "Tip: stand in your territory ring at payout for bonus cash.")
                end
            end
        end
    end)
end
