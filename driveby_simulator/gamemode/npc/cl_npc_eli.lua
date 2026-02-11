-- gamemode/npc/cl_npc_eli.lua

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

net.Receive("DBS_Eli_Open", function()
    local isPolice = net.ReadBool()
    local cred = net.ReadUInt(3)
    local money = net.ReadInt(32)

    local shop = isPolice and DBS.Config.Shop.Police or DBS.Config.Shop.Gang

    local frame = vgui.Create("DFrame")
    frame:SetSize(560, 500)
    frame:Center()
    frame:SetTitle("Eli — Dealer")
    frame:MakePopup()

    local sheet = vgui.Create("DPropertySheet", frame)
    sheet:Dock(FILL)
    sheet:DockMargin(6, 6, 6, 6)

    -- =========================
    -- BUY TAB
    -- =========================
    local buyPanel = vgui.Create("DScrollPanel", sheet)
    sheet:AddSheet("Buy", buyPanel, "icon16/cart.png")

    for tier = 0, shop.CredCap do
        local tierData = shop.Tiers[tier]
        if not tierData then continue end

        local header = buyPanel:Add("DLabel")
        header:SetFont("DermaLarge")
        header:SetText(tierData.Name .. (cred < tier and " (LOCKED)" or ""))
        header:Dock(TOP)
        header:DockMargin(4, tier == 0 and 4 or 16, 4, 6)
        header:SetTextColor(cred < tier and Color(180, 180, 180) or color_white)
        header:SizeToContents()

        for _, item in ipairs(tierData.Items) do
            local canAfford = money >= item.Price
            local tierUnlocked = cred >= tier

            local btn = buyPanel:Add("DButton")
            btn:Dock(TOP)
            btn:DockMargin(4, 2, 4, 2)
            btn:SetTall(32)

            local label = item.Name .. " — $" .. item.Price
            if not tierUnlocked then
                label = label .. " (Requires " .. tier .. " CRED)"
            elseif not canAfford then
                label = label .. " (Too Expensive)"
            end

            btn:SetText(label)
            btn:SetEnabled(tierUnlocked and canAfford)

            btn.DoClick = function()
                net.Start("DBS_Eli_Buy")
                    net.WriteUInt(tier, 3)
                    net.WriteString(item.Class)
                net.SendToServer()
            end
        end
    end

    -- =========================
    -- SELL TAB (LIVE REFRESH)
    -- =========================
    local sellPanel = vgui.Create("DScrollPanel", sheet)
    sheet:AddSheet("Sell", sellPanel, "icon16/money.png")

    local function PopulateSellTab()
        sellPanel:Clear()

        local weapons = LocalPlayer():GetWeapons()
        local sellable = {}

        for _, wep in ipairs(weapons) do
            if IsSellableWeapon(wep, shop) then
                table.insert(sellable, wep)
            end
        end

        -- Sell All button
        if #sellable > 1 then
            local sellAll = sellPanel:Add("DButton")
            sellAll:Dock(TOP)
            sellAll:DockMargin(4, 4, 4, 8)
            sellAll:SetTall(36)
            sellAll:SetText("Sell All")

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
            btn:DockMargin(4, 2, 4, 2)
            btn:SetTall(32)

            btn:SetText(NiceWeaponName(wep) .. " — Sell for $" .. price)

            btn.DoClick = function()
                net.Start("DBS_Eli_Sell")
                    net.WriteString(class)
                net.SendToServer()

                timer.Simple(0.15, PopulateSellTab)
            end
        end
    end

    PopulateSellTab()
end)
