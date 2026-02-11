-- gamemode/npc/cl_npc_eli.lua

local ELI_FRAME

local function NiceWeaponName(wep)
    if not IsValid(wep) then return "Unknown" end
    local pn = wep.PrintName
    if pn and pn ~= "" and pn ~= "Scripted Weapon" then return pn end
    return wep:GetClass()
end

local function IsSellableWeapon(wep, shop)
    if not IsValid(wep) then return false end

    local class = wep:GetClass()

    if DBS.Inventory and DBS.Inventory.IgnoreWeapons and DBS.Inventory.IgnoreWeapons[class] then return false end
    if class == "weapon_dbs_lockpick" then return false end
    if wep.AdminOnly then return false end
    if not shop.SellPrices or not shop.SellPrices[class] then return false end

    return true
end

local function PaintStyledFrame(frame, title, subtitle)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 14, 18, 242))
        draw.RoundedBox(12, 0, 0, w, 56, Color(20, 24, 30, 250))
        draw.SimpleText(title, "DBS_UI_Title", 14, 18, color_white, TEXT_ALIGN_LEFT)
        draw.SimpleText(subtitle, "DBS_UI_Body", 14, 43, Color(180, 180, 180), TEXT_ALIGN_LEFT)
    end
end

local function StyleButton(btn, enabled)
    btn:SetText("")
    btn.Paint = function(self, w, h)
        local base = enabled and Color(45, 100, 155, 255) or Color(75, 75, 75, 220)
        if enabled and self:IsHovered() then
            base = Color(65, 120, 175, 255)
        end

        draw.RoundedBox(8, 0, 0, w, h, base)
        draw.SimpleText(self.DBS_Label or "", "DBS_UI_Body", 12, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

net.Receive("DBS_Eli_Open", function()
    local isPolice = net.ReadBool()
    local cred = net.ReadUInt(3)
    local money = net.ReadInt(32)
    local printerOwned = net.ReadUInt(8)
    local printerMax = math.max(1, net.ReadUInt(8))
    local cokeOwned = net.ReadUInt(8)
    local cokeMax = math.max(1, net.ReadUInt(8))
    local dryOwned = net.ReadUInt(8)
    local dryMax = math.max(1, net.ReadUInt(8))
    local packOwned = net.ReadUInt(8)
    local packMax = math.max(1, net.ReadUInt(8))

    local shop = isPolice and DBS.Config.Shop.Police or DBS.Config.Shop.Gang

    if IsValid(ELI_FRAME) then ELI_FRAME:Remove() end

    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 520)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()

    PaintStyledFrame(frame, "Eli's Market", "Street gear, utilities, no questions.")

    ELI_FRAME = frame

    local hint = frame:Add("DLabel")
    hint:SetPos(14, 60)
    hint:SetFont("DBS_UI_Body")
    hint:SetTextColor(Color(180, 180, 180))
    hint:SetText("Hint: F2 manages properties • F1 toggles camera")
    hint:SizeToContents()

    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    sheet:DockMargin(10, 76, 10, 10)

    -- BUY TAB
    local buyPanel = vgui.Create("DScrollPanel", sheet)
    sheet:AddSheet("Buy", buyPanel, "icon16/cart.png")

    for tier = 0, shop.CredCap do
        local tierData = shop.Tiers[tier]
        if not tierData then continue end

        local header = buyPanel:Add("DLabel")
        header:SetFont("DBS_UI_Title")
        header:SetText(tierData.Name .. (cred < tier and " (LOCKED)" or ""))
        header:Dock(TOP)
        header:DockMargin(4, tier == 0 and 2 or 14, 4, 6)
        header:SetTall(24)
        header:SetContentAlignment(4)
        header:SetTextColor(cred < tier and Color(150, 150, 150) or color_white)

        for _, item in ipairs(tierData.Items) do
            local canAfford = money >= item.Price
            local tierUnlocked = cred >= tier
            local enabled = tierUnlocked and canAfford

            local btn = buyPanel:Add("DButton")
            btn:Dock(TOP)
            btn:DockMargin(4, 0, 4, 8)
            btn:SetTall(34)
            btn:SetEnabled(enabled)

            local label = item.Name .. "  —  $" .. string.Comma(item.Price)
            if not tierUnlocked then
                label = label .. "   (Requires " .. tier .. " CRED)"
            elseif not canAfford then
                label = label .. "   (Too expensive)"
            end

            btn.DBS_Label = label
            StyleButton(btn, enabled)

            btn.DoClick = function()
                net.Start("DBS_Eli_Buy")
                    net.WriteUInt(tier, 3)
                    net.WriteString(item.Class)
                net.SendToServer()
            end
        end
    end

    -- SELL TAB
    local sellPanel = vgui.Create("DScrollPanel", sheet)
    sheet:AddSheet("Sell", sellPanel, "icon16/money.png")

    local function PopulateSellTab()
        sellPanel:Clear()

        local weapons = LocalPlayer():GetWeapons()
        local sellable = {}

        for _, wep in ipairs(weapons) do
            if IsSellableWeapon(wep, shop) then
                sellable[#sellable + 1] = wep
            end
        end

        if #sellable > 1 then
            local sellAll = sellPanel:Add("DButton")
            sellAll:Dock(TOP)
            sellAll:DockMargin(4, 4, 4, 8)
            sellAll:SetTall(36)
            sellAll:SetText("")
            sellAll.DBS_Label = "Sell All"
            StyleButton(sellAll, true)

            sellAll.DoClick = function()
                for _, wep in ipairs(sellable) do
                    if LocalPlayer():GetActiveWeapon() == wep then continue end

                    net.Start("DBS_Eli_Sell")
                        net.WriteString(wep:GetClass())
                    net.SendToServer()
                end

                timer.Simple(0.15, PopulateSellTab)
            end
        end

        if #sellable == 0 then
            local lbl = sellPanel:Add("DLabel")
            lbl:SetText("You have nothing sellable.")
            lbl:SetFont("DBS_UI_Body")
            lbl:Dock(TOP)
            lbl:DockMargin(6, 6, 6, 0)
            lbl:SetTextColor(Color(200, 200, 200))
            lbl:SizeToContents()
            return
        end

        for _, wep in ipairs(sellable) do
            local class = wep:GetClass()
            local price = shop.SellPrices[class]

            local btn = sellPanel:Add("DButton")
            btn:Dock(TOP)
            btn:DockMargin(4, 0, 4, 8)
            btn:SetTall(34)
            btn:SetText("")
            btn.DBS_Label = NiceWeaponName(wep) .. "  —  Sell for $" .. string.Comma(price)
            StyleButton(btn, true)

            btn.DoClick = function()
                net.Start("DBS_Eli_Sell")
                    net.WriteString(class)
                net.SendToServer()

                timer.Simple(0.15, PopulateSellTab)
            end
        end
    end

    PopulateSellTab()

    local utilPanel = vgui.Create("DPanel", sheet)
    utilPanel:DockPadding(10, 10, 10, 10)
    utilPanel.Paint = nil
    sheet:AddSheet("Utility", utilPanel, "icon16/wrench.png")

    local pCfg = DBS.Config.Printer or {}
    local pPrice = pCfg.Price or 3000
    local cCfg = DBS.Config.CokePrinter or {}
    local cPrice = cCfg.Price or 9000
    local atPrinterCap = printerOwned >= printerMax
    local atCokeCap = cokeOwned >= cokeMax

    local prInfo = utilPanel:Add("DLabel")
    prInfo:Dock(TOP)
    prInfo:SetFont("DBS_UI_Body")
    prInfo:SetTextColor(Color(220,220,220))
    prInfo:SetWrap(true)
    prInfo:SetAutoStretchVertical(true)
    prInfo:SetText("Money Printer " .. printerOwned .. "/" .. printerMax .. "\nPrice: $" .. string.Comma(pPrice) .. "\nLow passive income. Collect by using the printer.")

    local prBtn = utilPanel:Add("DButton")
    prBtn:Dock(TOP)
    prBtn:DockMargin(0, 8, 0, 0)
    prBtn:SetTall(36)
    prBtn:SetText("")
    prBtn.DBS_Label = "Buy Money Printer (" .. printerOwned .. "/" .. printerMax .. ")"
    StyleButton(prBtn, (money >= pPrice) and not atPrinterCap)
    prBtn:SetEnabled((money >= pPrice) and not atPrinterCap)
    prBtn.DoClick = function()
        if atPrinterCap then return end
        net.Start("DBS_Eli_BuyPrinter")
        net.SendToServer()
    end

    local cokeInfo = utilPanel:Add("DLabel")
    cokeInfo:Dock(TOP)
    cokeInfo:DockMargin(0, 14, 0, 0)
    cokeInfo:SetFont("DBS_UI_Body")
    cokeInfo:SetTextColor(Color(220,220,220))
    cokeInfo:SetWrap(true)
    cokeInfo:SetAutoStretchVertical(true)
    cokeInfo:SetText("Coke Processor " .. cokeOwned .. "/" .. cokeMax .. "\nPrice: $" .. string.Comma(cPrice) .. "\nLoad supplies (sprint+use), then collect wet batches.")

    local cokeBtn = utilPanel:Add("DButton")
    cokeBtn:Dock(TOP)
    cokeBtn:DockMargin(0, 8, 0, 0)
    cokeBtn:SetTall(36)
    cokeBtn:SetText("")
    cokeBtn.DBS_Label = "Buy Coke Processor (" .. cokeOwned .. "/" .. cokeMax .. ")"
    StyleButton(cokeBtn, (money >= cPrice) and not atCokeCap)
    cokeBtn:SetEnabled((money >= cPrice) and not atCokeCap)
    cokeBtn.DoClick = function()
        if atCokeCap then return end
        net.Start("DBS_Eli_BuyCokePrinter")
        net.SendToServer()
    end

    local dCfg = DBS.Config.CokeDryingTable or {}
    local dPrice = dCfg.Price or 3000
    local atDryCap = dryOwned >= dryMax

    local dryInfo = utilPanel:Add("DLabel")
    dryInfo:Dock(TOP)
    dryInfo:DockMargin(0, 14, 0, 0)
    dryInfo:SetFont("DBS_UI_Body")
    dryInfo:SetTextColor(Color(220,220,220))
    dryInfo:SetWrap(true)
    dryInfo:SetAutoStretchVertical(true)
    dryInfo:SetText("Coke Drying Table " .. dryOwned .. "/" .. dryMax .. "\nPrice: $" .. string.Comma(dPrice) .. "\nDry wet batches into dry batches.")

    local dryBtn = utilPanel:Add("DButton")
    dryBtn:Dock(TOP)
    dryBtn:DockMargin(0, 8, 0, 0)
    dryBtn:SetTall(36)
    dryBtn:SetText("")
    dryBtn.DBS_Label = "Buy Coke Drying Table (" .. dryOwned .. "/" .. dryMax .. ")"
    StyleButton(dryBtn, (money >= dPrice) and not atDryCap)
    dryBtn:SetEnabled((money >= dPrice) and not atDryCap)
    dryBtn.DoClick = function()
        if atDryCap then return end
        net.Start("DBS_Eli_BuyDryingTable")
        net.SendToServer()
    end

    local bCfg = DBS.Config.CokeBrickPacker or {}
    local bPrice = bCfg.Price or 4500
    local atPackerCap = packOwned >= packMax

    local packInfo = utilPanel:Add("DLabel")
    packInfo:Dock(TOP)
    packInfo:DockMargin(0, 14, 0, 0)
    packInfo:SetFont("DBS_UI_Body")
    packInfo:SetTextColor(Color(220,220,220))
    packInfo:SetWrap(true)
    packInfo:SetAutoStretchVertical(true)
    packInfo:SetText("Coke Brick Packer " .. packOwned .. "/" .. packMax .. "\nPrice: $" .. string.Comma(bPrice) .. "\nPack dry batches into coke bricks.")

    local packBtn = utilPanel:Add("DButton")
    packBtn:Dock(TOP)
    packBtn:DockMargin(0, 8, 0, 0)
    packBtn:SetTall(36)
    packBtn:SetText("")
    packBtn.DBS_Label = "Buy Coke Brick Packer (" .. packOwned .. "/" .. packMax .. ")"
    StyleButton(packBtn, (money >= bPrice) and not atPackerCap)
    packBtn:SetEnabled((money >= bPrice) and not atPackerCap)
    packBtn.DoClick = function()
        if atPackerCap then return end
        net.Start("DBS_Eli_BuyBrickPacker")
        net.SendToServer()
    end

end)
