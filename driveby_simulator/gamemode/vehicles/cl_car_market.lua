if not CLIENT then return end

local CAR_FRAME
local STOCK = {}
local AUCTIONS = {}
local SAVED_CAR = {}

local SELECTED_INDEX = 1
local PREVIEW_COLOR = Color(255, 255, 255)
local PREVIEW_BGS = {}

local function Send(action, fn)
    net.Start("DBS_Car_Action")
        net.WriteString(action)
        if fn then fn() end
    net.SendToServer()
end

local function PaintFrame(frame)
    frame.Paint = function(_, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 14, 18, 242))
        draw.RoundedBox(12, 0, 0, w, 56, Color(20, 24, 30, 250))
        draw.SimpleText("Car Dealer / Auction House", "DBS_UI_Title", 14, 18, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText("Preview, customize, then spawn.", "DBS_UI_Body", 14, 42, Color(180, 180, 180), TEXT_ALIGN_LEFT)
    end
end

local function StyleButton(btn)
    btn:SetText("")
    btn.Paint = function(self, w, h)
        local enabled = self:IsEnabled()
        local col = enabled and Color(45, 100, 155, 255) or Color(75, 75, 75, 220)
        if enabled and self:IsHovered() then col = Color(65, 120, 175, 255) end
        draw.RoundedBox(8, 0, 0, w, h, col)
        draw.SimpleText(self.DBS_Label or "", "DBS_UI_Body", 10, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

local function IsStockVisible(stock)
    if not stock then return false end
    if stock.PoliceOnly and not DBS.Util.IsPolice(LocalPlayer()) then
        return false
    end
    return true
end

local function BuildBodygroupSliders(parent, modelPanel, stock)
    PREVIEW_BGS = {}
    if not IsValid(modelPanel.Entity) then return end

    local ent = modelPanel.Entity
    local bgCount = ent:GetNumBodyGroups() or 0
    for i = 0, bgCount - 1 do
        local num = ent:GetBodygroupCount(i) or 1
        if num <= 1 then continue end

        local slider = parent:Add("DNumSlider")
        slider:Dock(TOP)
        slider:DockMargin(4, 0, 4, 2)
        slider:SetText("Bodygroup " .. i)
        slider:SetMin(0)
        slider:SetMax(num - 1)
        slider:SetDecimals(0)
        slider:SetValue(0)
        slider.OnValueChanged = function(_, val)
            local idx = math.Clamp(math.floor(val + 0.5), 0, num - 1)
            PREVIEW_BGS[i] = idx
            if IsValid(modelPanel.Entity) then
                modelPanel.Entity:SetBodygroup(i, idx)
            end
        end
    end
end

local function ApplyPreview(modelPanel, stock, bgPanel)
    if not stock then return end

    local mdl = stock.Model or "models/buggy.mdl"
    if not util.IsValidModel(mdl) then mdl = "models/buggy.mdl" end
    modelPanel:SetModel(mdl)
    if IsValid(modelPanel.Entity) then
        modelPanel.Entity:SetColor(PREVIEW_COLOR)
        modelPanel.Entity:SetSkin(0)
        for id, val in pairs(PREVIEW_BGS) do
            modelPanel.Entity:SetBodygroup(id, val)
        end
    end

    if IsValid(bgPanel) then
        bgPanel:Clear()
        BuildBodygroupSliders(bgPanel, modelPanel, stock)
    end
end

local function BuildUI()
    if IsValid(CAR_FRAME) then CAR_FRAME:Remove() end

    CAR_FRAME = vgui.Create("DFrame")
    CAR_FRAME:SetSize(860, 560)
    CAR_FRAME:Center()
    CAR_FRAME:SetTitle("")
    CAR_FRAME:MakePopup()
    PaintFrame(CAR_FRAME)

    local sheet = vgui.Create("DPropertySheet", CAR_FRAME)
    sheet:Dock(FILL)
    sheet:DockMargin(10, 62, 10, 10)

    local dealer = vgui.Create("DPanel", sheet)
    dealer:Dock(FILL)
    dealer.Paint = nil
    sheet:AddSheet("Dealer", dealer, "icon16/car.png")

    local left = dealer:Add("DScrollPanel")
    left:Dock(LEFT)
    left:SetWide(330)
    left:DockMargin(0, 0, 8, 0)

    local right = dealer:Add("DPanel")
    right:Dock(FILL)
    right.Paint = nil

    local modelPanel = right:Add("DModelPanel")
    modelPanel:Dock(TOP)
    modelPanel:SetTall(250)
    modelPanel:SetCamPos(Vector(240, 0, 80))
    modelPanel:SetLookAt(Vector(0, 0, 40))
    modelPanel.LayoutEntity = function(self, ent)
        ent:SetAngles(Angle(0, CurTime() * 12 % 360, 0))
    end

    local mixer = right:Add("DColorMixer")
    mixer:Dock(TOP)
    mixer:SetTall(120)
    mixer:SetPalette(true)
    mixer:SetAlphaBar(false)
    mixer:SetWangs(true)
    mixer:SetColor(PREVIEW_COLOR)
    mixer.ValueChanged = function(_, col)
        PREVIEW_COLOR = Color(col.r, col.g, col.b)
        if IsValid(modelPanel.Entity) then
            modelPanel.Entity:SetColor(PREVIEW_COLOR)
        end
    end

    local bgPanel = right:Add("DScrollPanel")
    bgPanel:Dock(FILL)
    bgPanel:DockMargin(0, 6, 0, 6)

    local buyBtn = right:Add("DButton")
    buyBtn:Dock(BOTTOM)
    buyBtn:SetTall(36)
    buyBtn.DBS_Label = "Buy Previewed Car"
    StyleButton(buyBtn)

    local previewBtn = right:Add("DButton")
    previewBtn:Dock(BOTTOM)
    previewBtn:DockMargin(0, 0, 0, 6)
    previewBtn:SetTall(32)
    previewBtn.DBS_Label = "Preview Selected Car"
    StyleButton(previewBtn)

    local spawnSavedBtn = right:Add("DButton")
    spawnSavedBtn:Dock(BOTTOM)
    spawnSavedBtn:DockMargin(0, 0, 0, 6)
    spawnSavedBtn:SetTall(32)
    spawnSavedBtn.DBS_Label = "Spawn Saved Car"
    StyleButton(spawnSavedBtn)

    local function SelectStock(index)
        SELECTED_INDEX = index
        PREVIEW_BGS = {}
        ApplyPreview(modelPanel, STOCK[index], bgPanel)
        local stock = STOCK[index]
        if stock then
            buyBtn.DBS_Label = "Buy " .. (stock.Name or "Car") .. " ($" .. string.Comma(stock.Price or 0) .. ")"
        end
    end

    for i, c in ipairs(STOCK) do
        if not IsStockVisible(c) then continue end

        local btn = left:Add("DButton")
        btn:Dock(TOP)
        btn:DockMargin(4, 4, 4, 0)
        btn:SetTall(34)
        btn.DBS_Label = (c.Name or "Car") .. " - $" .. string.Comma(c.Price or 0)
        StyleButton(btn)
        btn.DoClick = function() SelectStock(i) end
    end

    previewBtn.DoClick = function()
        SelectStock(SELECTED_INDEX)
    end

    spawnSavedBtn.DoClick = function()
        Send("spawn_saved")
    end

    buyBtn.DoClick = function()
        local stock = STOCK[SELECTED_INDEX]
        if not stock then return end

        Send("buy_npc", function()
            net.WriteUInt(SELECTED_INDEX, 8)
            net.WriteUInt(PREVIEW_COLOR.r, 8)
            net.WriteUInt(PREVIEW_COLOR.g, 8)
            net.WriteUInt(PREVIEW_COLOR.b, 8)

            local count = 0
            for _ in pairs(PREVIEW_BGS) do count = count + 1 end
            net.WriteUInt(math.min(16, count), 5)
            local written = 0
            for id, val in pairs(PREVIEW_BGS) do
                if written >= 16 then break end
                net.WriteUInt(id, 5)
                net.WriteUInt(val, 6)
                written = written + 1
            end
        end)
    end

    SelectStock(SELECTED_INDEX)

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
    listBtn.DBS_Label = "List my current car"
    StyleButton(listBtn)
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
        pnl.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(20, 20, 20, 220))
            draw.SimpleText((a.Name or "Car") .. " by " .. (a.SellerName or "Unknown"), "DermaDefaultBold", 8, 10, color_white)
            draw.SimpleText("Bid: $" .. string.Comma(a.Bid or 0) .. "  Buyout: $" .. string.Comma(a.Buyout or 0), "DermaDefault", 8, 30, Color(180, 180, 180))
            if a.BidderName then draw.SimpleText("Top bidder: " .. a.BidderName, "DermaDefault", 8, 46, Color(160, 220, 160)) end
        end

        local bid = vgui.Create("DButton", pnl)
        bid:SetPos(8, 60)
        bid:SetSize(110, 20)
        bid.DBS_Label = "Bid +$500"
        StyleButton(bid)
        bid.DoClick = function()
            Send("bid", function()
                net.WriteUInt(id, 16)
                net.WriteInt((a.Bid or 0) + 500, 32)
            end)
        end

        local buy = vgui.Create("DButton", pnl)
        buy:SetPos(126, 60)
        buy:SetSize(110, 20)
        buy.DBS_Label = "Buyout"
        StyleButton(buy)
        buy.DoClick = function()
            Send("buyout", function() net.WriteUInt(id, 16) end)
        end
    end
end

net.Receive("DBS_Car_Open", function()
    STOCK = net.ReadTable() or {}
    AUCTIONS = net.ReadTable() or {}
    SAVED_CAR = net.ReadTable() or {}

    if istable(SAVED_CAR.Color) then
        PREVIEW_COLOR = Color(tonumber(SAVED_CAR.Color.r) or 255, tonumber(SAVED_CAR.Color.g) or 255, tonumber(SAVED_CAR.Color.b) or 255)
        PREVIEW_BGS = SAVED_CAR.Bodygroups or {}
    end

    BuildUI()
end)

net.Receive("DBS_Car_Update", function()
    AUCTIONS = net.ReadTable() or {}
    if IsValid(CAR_FRAME) then BuildUI() end
end)
