DBS = DBS or {}
DBS.CarMarket = DBS.CarMarket or {}

util.AddNetworkString("DBS_Car_Open")
util.AddNetworkString("DBS_Car_Action")
util.AddNetworkString("DBS_Car_Update")

DBS.CarMarket.Auctions = DBS.CarMarket.Auctions or {}
DBS.CarMarket.NextAuctionID = DBS.CarMarket.NextAuctionID or 1

local AMBIENT_DATA_FILE = "dbs/car_spawns_" .. game.GetMap() .. ".json"

local function GetAmbientConfig()
    local cfg = DBS.Config.CarsDealer or {}
    return {
        max = math.max(0, tonumber(cfg.AmbientMax) or 10),
        interval = math.max(8, tonumber(cfg.AmbientInterval) or 18),
        points = table.Copy(cfg.SpawnPositions or {})
    }
end

local function EncodeVec(vec)
    if isvector(vec) then
        return { x = vec.x, y = vec.y, z = vec.z }
    end

    return { x = 0, y = 0, z = 0 }
end

local function EncodeAng(ang)
    if isangle(ang) then
        return { p = ang.p, y = ang.y, r = ang.r }
    end

    return { p = 0, y = 0, r = 0 }
end

local function DecodeVec(raw)
    if isvector(raw) then return raw end
    if not istable(raw) then return nil end

    local x = tonumber(raw.x)
    local y = tonumber(raw.y)
    local z = tonumber(raw.z)
    if not x or not y or not z then return nil end

    return Vector(x, y, z)
end

local function DecodeAng(raw)
    if isangle(raw) then return raw end
    if not istable(raw) then return Angle(0, 0, 0) end

    return Angle(tonumber(raw.p) or 0, tonumber(raw.y) or 0, tonumber(raw.r) or 0)
end

local function NormalizeSpawnPoint(spot)
    if not istable(spot) then return nil end

    local pos = DecodeVec(spot.Pos or spot.pos)
    if not pos then return nil end

    return {
        Pos = pos,
        Ang = DecodeAng(spot.Ang or spot.ang)
    }
end

local function NormalizeSpawnPoints(points)
    local normalized = {}
    for _, spot in ipairs(points or {}) do
        local parsed = NormalizeSpawnPoint(spot)
        if parsed then
            normalized[#normalized + 1] = parsed
        end
    end

    return normalized
end

local function SerializeSpawnPoints(points)
    local saved = {}
    for _, spot in ipairs(points or {}) do
        local parsed = NormalizeSpawnPoint(spot)
        if parsed then
            saved[#saved + 1] = {
                pos = EncodeVec(parsed.Pos),
                ang = EncodeAng(parsed.Ang)
            }
        end
    end

    return saved
end

local function SaveAmbientConfig(data)
    local payload = {
        max = math.max(0, tonumber(data and data.max) or 0),
        interval = math.max(8, tonumber(data and data.interval) or 18),
        points = SerializeSpawnPoints(data and data.points or {})
    }

    if not file.IsDir("dbs", "DATA") then file.CreateDir("dbs") end
    file.Write(AMBIENT_DATA_FILE, util.TableToJSON(payload, true))
end

local function LoadAmbientConfig()
    local base = GetAmbientConfig()
    if not file.Exists(AMBIENT_DATA_FILE, "DATA") then
        DBS.CarMarket.AmbientCfg = base
        return
    end

    local parsed = util.JSONToTable(file.Read(AMBIENT_DATA_FILE, "DATA") or "")
    if not istable(parsed) then
        DBS.CarMarket.AmbientCfg = base
        return
    end

    base.max = math.max(0, tonumber(parsed.max) or base.max)
    base.interval = math.max(8, tonumber(parsed.interval) or base.interval)
    if istable(parsed.points) then base.points = NormalizeSpawnPoints(parsed.points) end

    DBS.CarMarket.AmbientCfg = base
end

function DBS.CarMarket.AddAmbientSpawn(pos, ang)
    LoadAmbientConfig()
    local cfg = DBS.CarMarket.AmbientCfg
    cfg.points = cfg.points or {}
    cfg.points[#cfg.points + 1] = {
        Pos = isvector(pos) and pos or Vector(0, 0, 0),
        Ang = isangle(ang) and ang or Angle(0, 0, 0)
    }
    SaveAmbientConfig(cfg)
end

function DBS.CarMarket.RemoveNearestAmbientSpawn(pos)
    LoadAmbientConfig()
    local cfg = DBS.CarMarket.AmbientCfg
    local best, bestDist
    for i, spot in ipairs(cfg.points or {}) do
        local d = pos:DistToSqr(spot.Pos)
        if not bestDist or d < bestDist then
            best = i
            bestDist = d
        end
    end

    if best and bestDist and bestDist <= (280 * 280) then
        table.remove(cfg.points, best)
        SaveAmbientConfig(cfg)
        return true
    end

    return false
end

function DBS.CarMarket.SetAmbientSettings(maxCount, interval)
    LoadAmbientConfig()
    DBS.CarMarket.AmbientCfg.max = math.max(0, tonumber(maxCount) or DBS.CarMarket.AmbientCfg.max)
    DBS.CarMarket.AmbientCfg.interval = math.max(8, tonumber(interval) or DBS.CarMarket.AmbientCfg.interval)
    SaveAmbientConfig(DBS.CarMarket.AmbientCfg)

    timer.Remove("DBS.CarMarket.AmbientRefresh")
    timer.Create("DBS.CarMarket.AmbientRefresh", DBS.CarMarket.AmbientCfg.interval, 0, function()
        if DBS.CarMarket.SpawnOneAmbientCar then DBS.CarMarket.SpawnOneAmbientCar() end
    end)
end

local function BroadcastState(target)
    net.Start("DBS_Car_Update")
        net.WriteTable(DBS.CarMarket.Auctions)
    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

local function GetSpawnList()
    if DBS.CarMarket and DBS.CarMarket.AmbientCfg and istable(DBS.CarMarket.AmbientCfg.points) and #DBS.CarMarket.AmbientCfg.points > 0 then
        return DBS.CarMarket.AmbientCfg.points
    end
    return (DBS.Config.CarsDealer and DBS.Config.CarsDealer.SpawnPositions) or {}
end

local function FindSpawnPos(requireFarFromPlayers)
    local list = GetSpawnList()
    if #list == 0 then return nil end

    local candidates = table.Copy(list)
    table.Shuffle(candidates)

    for _, spot in ipairs(candidates) do
        if not util.IsInWorld(spot.Pos) then continue end

        if requireFarFromPlayers then
            local ok = true
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:Alive() and ply:GetPos():DistToSqr(spot.Pos) < (900 * 900) then
                    ok = false
                    break
                end
            end
            if not ok then continue end
        end

        local blocked = false
        for _, ent in ipairs(ents.FindInSphere(spot.Pos, 180)) do
            if ent:IsVehicle() then
                blocked = true
                break
            end
        end

        if not blocked then
            return spot
        end
    end
end

local function SetupVehicleBase(ent)
    ent:SetKeyValue("vehiclescript", "scripts/vehicles/jeep_test.txt")
    ent:SetKeyValue("limitview", "0")
end

local function SpawnCar(ply, stock, owned)
    local spawn = FindSpawnPos(owned)
    if not spawn then return nil, "No clear car spawn position available." end

    local class = stock.Class or "prop_vehicle_jeep"
    local ent = ents.Create(class)
    if not IsValid(ent) then return nil, "Could not create vehicle." end

    ent:SetModel(stock.Model or "models/buggy.mdl")
    ent:SetPos(spawn.Pos)
    ent:SetAngles(spawn.Ang or Angle(0, 0, 0))

    if class == "prop_vehicle_jeep" or class == "prop_vehicle_airboat" then
        SetupVehicleBase(ent)
    end

    ent:Spawn()
    ent:Activate()

    if not IsValid(ent) then return nil, "Vehicle failed to spawn." end

    ent:SetNWString("DBS_CarName", stock.Name or "Car")
    if owned and IsValid(ply) then
        ent:SetNWString("DBS_CarOwner", ply:SteamID64())
    end

    return ent
end

local function GetOwnedCar(ply)
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetNWString("DBS_CarOwner", "") == ply:SteamID64() then
            return ent
        end
    end
end

local function SpawnOwnedCar(ply, stock)
    return SpawnCar(ply, stock, true)
end

function DBS.CarMarket.Open(ply)
    net.Start("DBS_Car_Open")
        net.WriteTable(DBS.Config.CarsDealer and DBS.Config.CarsDealer.Stock or {})
        net.WriteTable(DBS.CarMarket.Auctions)
    net.Send(ply)
end

function DBS.CarMarket.SpawnOneAmbientCar()
    local cfg = DBS.Config.CarsDealer or {}
    if not cfg.Stock or #cfg.Stock == 0 then return end

    LoadAmbientConfig()

    local maxAmbient = (DBS.CarMarket.AmbientCfg and DBS.CarMarket.AmbientCfg.max) or (cfg.AmbientMax or 10)
    local current = 0
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetNWBool("DBS_AmbientCar", false) then
            current = current + 1
        end
    end

    if current >= maxAmbient then return end

    local stock = table.Random(cfg.Stock)
    local ent = SpawnCar(NULL, stock, false)
    if IsValid(ent) then
        ent:SetNWBool("DBS_AmbientCar", true)
        ent:SetColor(Color(180, 180, 180))
    end
end

hook.Add("InitPostEntity", "DBS.CarMarket.AmbientInit", function()
    LoadAmbientConfig()
    timer.Simple(2, function() if DBS.CarMarket.SpawnOneAmbientCar then DBS.CarMarket.SpawnOneAmbientCar() end end)

    local interval = (DBS.CarMarket.AmbientCfg and DBS.CarMarket.AmbientCfg.interval) or 18
    timer.Create("DBS.CarMarket.AmbientRefresh", interval, 0, function()
        if DBS.CarMarket.SpawnOneAmbientCar then DBS.CarMarket.SpawnOneAmbientCar() end
    end)
end)

net.Receive("DBS_Car_Action", function(_, ply)
    if not IsValid(ply) then return end

    local action = net.ReadString()

    if action == "buy_npc" then
        local index = net.ReadUInt(8)
        local clr = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8))
        local bgCount = net.ReadUInt(5)
        local bodygroups = {}
        for _ = 1, bgCount do
            local id = net.ReadUInt(5)
            local val = net.ReadUInt(6)
            bodygroups[id] = val
        end

        local stock = DBS.Config.CarsDealer and DBS.Config.CarsDealer.Stock and DBS.Config.CarsDealer.Stock[index]
        if not stock then return end
        if stock.PoliceOnly and not DBS.Util.IsPolice(ply) then DBS.Util.Notify(ply, "Police only vehicle.") return end
        if not ply:CanAfford(stock.Price) then DBS.Util.Notify(ply, "Can't afford this car.") return end
        if IsValid(GetOwnedCar(ply)) then DBS.Util.Notify(ply, "Sell your current car first.") return end

        local ent, err = SpawnOwnedCar(ply, stock)
        if not IsValid(ent) then DBS.Util.Notify(ply, err or "Failed to buy.") return end

        ent:SetColor(clr)
        for id, val in pairs(bodygroups) do
            ent:SetBodygroup(id, val)
        end

        ply:AddMoney(-stock.Price)
        DBS.Util.Notify(ply, "Bought " .. (stock.Name or "car") .. ".")
        return
    end

    if action == "customize" then
        local car = GetOwnedCar(ply)
        if not IsValid(car) then DBS.Util.Notify(ply, "No owned car to customize.") return end

        local r = net.ReadUInt(8)
        local g = net.ReadUInt(8)
        local b = net.ReadUInt(8)
        car:SetColor(Color(r, g, b))
        DBS.Util.Notify(ply, "Car color updated.")
        return
    end

    if action == "sell_npc" then
        local car = GetOwnedCar(ply)
        if not IsValid(car) then DBS.Util.Notify(ply, "You don't own a spawned car.") return end

        local base = 5000
        local scale = DBS.Config.CarsDealer and DBS.Config.CarsDealer.BuybackScale or 0.6
        local payout = math.floor(base * scale)

        car:Remove()
        ply:AddMoney(payout)
        DBS.Util.Notify(ply, "Sold car to dealer for $" .. string.Comma(payout) .. ".")
        return
    end

    if action == "list_auction" then
        local buyout = net.ReadInt(32)
        local startBid = net.ReadInt(32)
        local car = GetOwnedCar(ply)
        if not IsValid(car) then DBS.Util.Notify(ply, "You need your car nearby.") return end

        local id = DBS.CarMarket.NextAuctionID
        DBS.CarMarket.NextAuctionID = id + 1

        DBS.CarMarket.Auctions[id] = {
            ID = id,
            Seller = ply:SteamID64(),
            SellerName = ply:Nick(),
            Name = car:GetNWString("DBS_CarName", "Car"),
            Model = car:GetModel(),
            Buyout = math.max(1, buyout),
            Bid = math.max(1, startBid),
            Bidder = ""
        }

        car:Remove()
        BroadcastState()
        DBS.Util.Notify(ply, "Car listed on auction house.")
        return
    end

    if action == "bid" then
        local id = net.ReadUInt(16)
        local amount = net.ReadInt(32)
        local a = DBS.CarMarket.Auctions[id]
        if not a then return end
        if a.Seller == ply:SteamID64() then return end
        if amount <= a.Bid then DBS.Util.Notify(ply, "Bid higher.") return end
        if not ply:CanAfford(amount) then DBS.Util.Notify(ply, "Can't afford that bid.") return end

        a.Bid = amount
        a.Bidder = ply:SteamID64()
        a.BidderName = ply:Nick()
        BroadcastState()
        return
    end

    if action == "buyout" then
        local id = net.ReadUInt(16)
        local a = DBS.CarMarket.Auctions[id]
        if not a then return end
        if a.Seller == ply:SteamID64() then return end
        if IsValid(GetOwnedCar(ply)) then DBS.Util.Notify(ply, "Sell your current car first.") return end
        if not ply:CanAfford(a.Buyout) then DBS.Util.Notify(ply, "Can't afford buyout.") return end

        ply:AddMoney(-a.Buyout)

        for _, p in ipairs(player.GetAll()) do
            if p:SteamID64() == a.Seller then
                p:AddMoney(a.Buyout)
                DBS.Util.Notify(p, "Your car sold for $" .. string.Comma(a.Buyout) .. ".")
            end
        end

        local ent, err = SpawnOwnedCar(ply, { Name = a.Name, Class = "prop_vehicle_jeep", Model = a.Model or "models/buggy.mdl" })
        if not IsValid(ent) then DBS.Util.Notify(ply, err or "Buyout failed to spawn car.") end

        DBS.CarMarket.Auctions[id] = nil
        BroadcastState()
        return
    end

    if action == "set_car_spawn" and ply:IsAdmin() then
        DBS.Config.CarsDealer.SpawnPositions = {
            { Pos = ply:GetPos(), Ang = ply:EyeAngles() }
        }
        DBS.Util.Notify(ply, "Set car spawn point.")
        return
    end

    if action == "add_car_spawn" and ply:IsAdmin() then
        DBS.Config.CarsDealer.SpawnPositions = DBS.Config.CarsDealer.SpawnPositions or {}
        table.insert(DBS.Config.CarsDealer.SpawnPositions, { Pos = ply:GetPos(), Ang = ply:EyeAngles() })
        DBS.Util.Notify(ply, "Added car spawn point (#" .. #DBS.Config.CarsDealer.SpawnPositions .. ").")
        return
    end
end)

function DBS.CarMarket.TrySpawnBonusCarFarFromPlayers()
    local cfg = DBS.Config.CarsDealer or {}
    if not cfg.Stock or #cfg.Stock == 0 then return false end

    local stock = table.Random(cfg.Stock)
    local ent = SpawnCar(NULL, stock, true)
    if not IsValid(ent) then return false end

    ent:SetNWBool("DBS_BonusCar", true)
    ent:SetColor(Color(210, 200, 120))
    return true
end
