if not CLIENT then return end

local CAR_FRAME
local STOCK = {}
local AUCTIONS = {}

local function Send(action, fn)
    net.Start("DBS_Car_Action")
        net.WriteString(action)
        if fn then fn() end
    net.SendToServer()
end

local function BuildUI()
    if IsValid(CAR_FRAME) then CAR_FRAME:Remove() end

    CAR_FRAME = vgui.Create("DFrame")
    CAR_FRAME:SetSize(620, 520)
    CAR_FRAME:Center()
    CAR_FRAME:SetTitle("Car Dealer / Auction House")
    CAR_FRAME:MakePopup()

    local sheet = vgui.Create("DPropertySheet", CAR_FRAME)
    sheet:Dock(FILL)

    local shop = vgui.Create("DScrollPanel", sheet)
    sheet:AddSheet("Dealer", shop, "icon16/car.png")

    for i, c in ipairs(STOCK) do
        local btn = shop:Add("DButton")
        btn:Dock(TOP)
        btn:DockMargin(4, 4, 4, 0)
        btn:SetTall(32)
        btn:SetText((c.Name or "Car") .. " - $" .. string.Comma(c.Price or 0))
        btn.DoClick = function()
            Send("buy_npc", function() net.WriteUInt(i, 8) end)
        end
    end


    local custom = shop:Add("DButton")
    custom:Dock(TOP)
    custom:DockMargin(4, 6, 4, 0)
    custom:SetTall(30)
    custom:SetText("Customize my car color (random)")
    custom.DoClick = function()
        Send("customize", function()
            net.WriteUInt(math.random(20,255), 8)
            net.WriteUInt(math.random(20,255), 8)
            net.WriteUInt(math.random(20,255), 8)
        end)
    end

    local sell = shop:Add("DButton")
    sell:Dock(TOP)
    sell:DockMargin(4, 10, 4, 0)
    sell:SetTall(34)
    sell:SetText("Sell my car back to NPC")
    sell.DoClick = function() Send("sell_npc") end

    local setSpawn = shop:Add("DButton")
    setSpawn:Dock(TOP)
    setSpawn:DockMargin(4, 10, 4, 0)
    setSpawn:SetTall(28)
    setSpawn:SetText("Admin: Set Car Spawn to my position")
    setSpawn.DoClick = function() Send("set_car_spawn") end

    local addSpawn = shop:Add("DButton")
    addSpawn:Dock(TOP)
    addSpawn:DockMargin(4, 4, 4, 0)
    addSpawn:SetTall(28)
    addSpawn:SetText("Admin: Add Car Spawn at my position")
    addSpawn.DoClick = function() Send("add_car_spawn") end

    local auction = vgui.Create("DScrollPanel", sheet)
    sheet:AddSheet("Auction", auction, "icon16/money_dollar.png")

    local buyoutEntry = auction:Add("DTextEntry")
    buyoutEntry:Dock(TOP)
    buyoutEntry:DockMargin(4, 4, 4, 4)
    buyoutEntry:SetPlaceholderText("Buyout price")

    local bidEntry = auction:Add("DTextEntry")
    bidEntry:Dock(TOP)
    bidEntry:DockMargin(4, 0, 4, 6)
    bidEntry:SetPlaceholderText("Starting bid")

    local listBtn = auction:Add("DButton")
    listBtn:Dock(TOP)
    listBtn:DockMargin(4, 0, 4, 10)
    listBtn:SetTall(32)
    listBtn:SetText("List my current car")
    listBtn.DoClick = function()
        local bo = tonumber(buyoutEntry:GetValue()) or 0
        local sb = tonumber(bidEntry:GetValue()) or 0
        Send("list_auction", function()
            net.WriteInt(bo, 32)
            net.WriteInt(sb, 32)
        end)
    end

    for id, a in pairs(AUCTIONS) do
        local pnl = auction:Add("DPanel")
        pnl:Dock(TOP)
        pnl:DockMargin(4, 0, 4, 8)
        pnl:SetTall(84)
        pnl.Paint = function(self,w,h)
            draw.RoundedBox(6,0,0,w,h,Color(20,20,20,220))
            draw.SimpleText(a.Name .. " by " .. a.SellerName, "DermaDefaultBold", 8, 10, color_white)
            draw.SimpleText("Bid: $"..string.Comma(a.Bid).."  Buyout: $"..string.Comma(a.Buyout), "DermaDefault", 8, 30, Color(180,180,180))
            if a.BidderName then draw.SimpleText("Top bidder: "..a.BidderName, "DermaDefault", 8, 46, Color(160,220,160)) end
        end

        local bid = vgui.Create("DButton", pnl)
        bid:SetPos(8, 60)
        bid:SetSize(110, 20)
        bid:SetText("Bid +$500")
        bid.DoClick = function()
            Send("bid", function()
                net.WriteUInt(id, 16)
                net.WriteInt((a.Bid or 0) + 500, 32)
            end)
        end

        local buy = vgui.Create("DButton", pnl)
        buy:SetPos(126, 60)
        buy:SetSize(110, 20)
        buy:SetText("Buyout")
        buy.DoClick = function()
            Send("buyout", function() net.WriteUInt(id, 16) end)
        end
    end
end

net.Receive("DBS_Car_Open", function()
    STOCK = net.ReadTable() or {}
    AUCTIONS = net.ReadTable() or {}
    BuildUI()
end)

net.Receive("DBS_Car_Update", function()
    AUCTIONS = net.ReadTable() or {}
    if IsValid(CAR_FRAME) then BuildUI() end
end)
