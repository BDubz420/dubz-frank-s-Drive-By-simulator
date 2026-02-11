DBS = DBS or {}
DBS.CarMarket = DBS.CarMarket or {}

util.AddNetworkString("DBS_Car_Open")
util.AddNetworkString("DBS_Car_Action")
util.AddNetworkString("DBS_Car_Update")

DBS.CarMarket.Auctions = DBS.CarMarket.Auctions or {}
DBS.CarMarket.NextAuctionID = DBS.CarMarket.NextAuctionID or 1

local AMBIENT_DATA_FILE = "dbs/car_spawns_" .. game.GetMap() .. ".json"
local PLAYER_DATA_FILE = "dbs/player_cars_" .. game.GetMap() .. ".json"
DBS.CarMarket.PlayerCars = DBS.CarMarket.PlayerCars or {}

local function LoadPlayerCars()
    if not file.Exists(PLAYER_DATA_FILE, "DATA") then DBS.CarMarket.PlayerCars = {} return end
    local parsed = util.JSONToTable(file.Read(PLAYER_DATA_FILE, "DATA") or "")
    DBS.CarMarket.PlayerCars = istable(parsed) and parsed or {}
end

local function SavePlayerCars()
    if not file.IsDir("dbs", "DATA") then file.CreateDir("dbs") end
    file.Write(PLAYER_DATA_FILE, util.TableToJSON(DBS.CarMarket.PlayerCars or {}, true))
end

local function GetAmbientConfig()
    local cfg = DBS.Config.CarsDealer or {}
    return {
        max = math.max(0, tonumber(cfg.AmbientMax) or 10),
        interval = math.max(8, tonumber(cfg.AmbientInterval) or 18),
        points = table.Copy(cfg.SpawnPositions or {}),
        allowed = {}
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
        points = SerializeSpawnPoints(data and data.points or {}),
        allowed = istable(data and data.allowed) and data.allowed or {}
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
    if istable(parsed.allowed) then base.allowed = parsed.allowed end

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

function DBS.CarMarket.SetAmbientAllowed(indices)
    LoadAmbientConfig()
    local out = {}
    for _, idx in ipairs(indices or {}) do
        local n = math.floor(tonumber(idx) or 0)
        if n > 0 then out[#out + 1] = n end
    end
    DBS.CarMarket.AmbientCfg.allowed = out
    SaveAmbientConfig(DBS.CarMarket.AmbientCfg)
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
    local sid = IsValid(ply) and ply:SteamID64() or ""
    local saved = DBS.CarMarket.PlayerCars[sid] or {}
    net.Start("DBS_Car_Open")
        net.WriteTable(DBS.Config.CarsDealer and DBS.Config.CarsDealer.Stock or {})
        net.WriteTable(DBS.CarMarket.Auctions)
        net.WriteTable(saved)
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

    local pool = {}
    local allowed = DBS.CarMarket.AmbientCfg and DBS.CarMarket.AmbientCfg.allowed or {}
    if istable(allowed) and #allowed > 0 then
        for _, idx in ipairs(allowed) do
            local st = cfg.Stock[tonumber(idx) or 0]
            if st then pool[#pool + 1] = st end
        end
    end
    if #pool == 0 then pool = cfg.Stock end

    local stock = table.Random(pool)
    local ent = SpawnCar(NULL, stock, false)
    if IsValid(ent) then
        ent:SetNWBool("DBS_AmbientCar", true)
        ent:SetColor(Color(180, 180, 180))
    end
end

hook.Add("InitPostEntity", "DBS.CarMarket.AmbientInit", function()
    LoadAmbientConfig()
    LoadPlayerCars()
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
        ent:SetNWString("DBS_CarClass", stock.Class or "prop_vehicle_jeep")
        ent:SetNWString("DBS_CarModel", stock.Model or "models/buggy.mdl")
        ent:SetNWString("DBS_CarName", stock.Name or "Car")

        local sid = ply:SteamID64()
        DBS.CarMarket.PlayerCars[sid] = {
            Class = stock.Class or "prop_vehicle_jeep",
            Model = stock.Model or "models/buggy.mdl",
            Name = stock.Name or "Car",
            Color = { r = clr.r, g = clr.g, b = clr.b },
            Bodygroups = bodygroups
        }
        SavePlayerCars()

        ply:AddMoney(-stock.Price)
        DBS.Util.Notify(ply, "Bought " .. (stock.Name or "car") .. ".")
        DBS.CarMarket.Open(ply)
        return
    end

    if action == "customize" then
        local car = GetOwnedCar(ply)
        if not IsValid(car) then DBS.Util.Notify(ply, "No owned car to customize.") return end

        local r = net.ReadUInt(8)
        local g = net.ReadUInt(8)
        local b = net.ReadUInt(8)
        car:SetColor(Color(r, g, b))

        local sid = ply:SteamID64()
        if istable(DBS.CarMarket.PlayerCars[sid]) then
            DBS.CarMarket.PlayerCars[sid].Color = { r = r, g = g, b = b }
            SavePlayerCars()
        end

        DBS.Util.Notify(ply, "Car color updated.")
        DBS.CarMarket.Open(ply)
        return
    end

    if action == "sell_npc" then
        local car = GetOwnedCar(ply)
        if not IsValid(car) then DBS.Util.Notify(ply, "You don't own a spawned car.") return end

        local base = 5000
        local scale = DBS.Config.CarsDealer and DBS.Config.CarsDealer.BuybackScale or 0.6
        local payout = math.floor(base * scale)

        car:Remove()
        DBS.CarMarket.PlayerCars[ply:SteamID64()] = nil
        SavePlayerCars()
        ply:AddMoney(payout)
        DBS.Util.Notify(ply, "Sold car to dealer for $" .. string.Comma(payout) .. ".")
        DBS.CarMarket.Open(ply)
        return
    end

    if action == "list_auction" then
        local buyout = net.ReadInt(32)
        local startBid = net.ReadInt(32)
        local car = GetOwnedCar(ply)
        if not IsValid(car) then DBS.Util.Notify(ply, "You need your car nearby.") return end

        local id = DBS.CarMarket.NextAuctionID
        DBS.CarMarket.NextAuctionID = id + 1

        local saved = DBS.CarMarket.PlayerCars[ply:SteamID64()] or {}
        DBS.CarMarket.Auctions[id] = {
            ID = id,
            Seller = ply:SteamID64(),
            SellerName = ply:Nick(),
            Name = car:GetNWString("DBS_CarName", saved.Name or "Car"),
            Class = car:GetNWString("DBS_CarClass", saved.Class or "prop_vehicle_jeep"),
            Model = car:GetNWString("DBS_CarModel", saved.Model or car:GetModel()),
            Color = saved.Color,
            Bodygroups = saved.Bodygroups,
            Buyout = math.max(1, buyout),
            Bid = math.max(1, startBid),
            Bidder = ""
        }

        car:Remove()
        DBS.CarMarket.PlayerCars[ply:SteamID64()] = nil
        SavePlayerCars()
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

        local previousBidder = a.Bidder
        local previousBid = a.Bid

        ply:AddMoney(-amount)
        a.Bid = amount
        a.Bidder = ply:SteamID64()
        a.BidderName = ply:Nick()

        if previousBidder and previousBidder ~= "" and previousBidder ~= ply:SteamID64() then
            for _, p2 in ipairs(player.GetAll()) do
                if p2:SteamID64() == previousBidder then
                    p2:AddMoney(previousBid)
                    DBS.Util.Notify(p2, "Outbid on auction. Refunded $" .. string.Comma(previousBid) .. ".")
                    break
                end
            end
        end

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

        if a.Bidder and a.Bidder ~= "" and a.Bidder ~= ply:SteamID64() then
            for _, p2 in ipairs(player.GetAll()) do
                if p2:SteamID64() == a.Bidder then
                    p2:AddMoney(a.Bid)
                    DBS.Util.Notify(p2, "Auction ended by buyout. Refunded your bid.")
                    break
                end
            end
        end

        ply:AddMoney(-a.Buyout)

        for _, p in ipairs(player.GetAll()) do
            if p:SteamID64() == a.Seller then
                p:AddMoney(a.Buyout)
                DBS.Util.Notify(p, "Your car sold for $" .. string.Comma(a.Buyout) .. ".")
            end
        end

        local stockData = { Name = a.Name, Class = a.Class or "prop_vehicle_jeep", Model = a.Model or "models/buggy.mdl" }
        local ent, err = SpawnOwnedCar(ply, stockData)
        if not IsValid(ent) then DBS.Util.Notify(ply, err or "Buyout failed to spawn car.") end

        if IsValid(ent) then
            local c = a.Color or { r = 255, g = 255, b = 255 }
            ent:SetColor(Color(tonumber(c.r) or 255, tonumber(c.g) or 255, tonumber(c.b) or 255))
            for bg, val in pairs(a.Bodygroups or {}) do
                ent:SetBodygroup(tonumber(bg) or 0, tonumber(val) or 0)
            end
            ent:SetNWString("DBS_CarClass", stockData.Class)
            ent:SetNWString("DBS_CarModel", stockData.Model)
            ent:SetNWString("DBS_CarName", stockData.Name)

            DBS.CarMarket.PlayerCars[ply:SteamID64()] = {
                Class = stockData.Class,
                Model = stockData.Model,
                Name = stockData.Name,
                Color = a.Color,
                Bodygroups = a.Bodygroups
            }
            SavePlayerCars()
        end

        DBS.CarMarket.Auctions[id] = nil
        BroadcastState()
        DBS.CarMarket.Open(ply)
        return
    end


    if action == "spawn_saved" then
        if IsValid(GetOwnedCar(ply)) then DBS.Util.Notify(ply, "Sell your current car first.") return end
        local saved = DBS.CarMarket.PlayerCars[ply:SteamID64()]
        if not istable(saved) then DBS.Util.Notify(ply, "No saved car profile.") return end

        local ent, err = SpawnOwnedCar(ply, saved)
        if not IsValid(ent) then DBS.Util.Notify(ply, err or "Failed to spawn saved car.") return end

        local c = saved.Color or { r = 255, g = 255, b = 255 }
        ent:SetColor(Color(tonumber(c.r) or 255, tonumber(c.g) or 255, tonumber(c.b) or 255))
        for bg, val in pairs(saved.Bodygroups or {}) do
            ent:SetBodygroup(tonumber(bg) or 0, tonumber(val) or 0)
        end
        ent:SetNWString("DBS_CarClass", saved.Class or "prop_vehicle_jeep")
        ent:SetNWString("DBS_CarModel", saved.Model or "models/buggy.mdl")
        ent:SetNWString("DBS_CarName", saved.Name or "Car")

        DBS.Util.Notify(ply, "Spawned your saved car setup.")
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
