local PLAYER = FindMetaTable("Player")

function PLAYER:GetMoney()
    return self:GetNWInt("DBS_Money", 0)
end

function PLAYER:SetMoney(amount)
    self:SetNWInt("DBS_Money", math.max(amount, 0))
end

function PLAYER:AddMoney(amount)
    self:SetMoney(self:GetMoney() + amount)
end

function PLAYER:CanAfford(amount)
    return self:GetMoney() >= amount
end

function PLAYER:CanRunEconomyAction(cooldown)
    cooldown = cooldown or 0

    local now = CurTime()
    local nextAllowed = self:GetNWFloat("DBS_EconCooldown", 0)

    if nextAllowed > now then
        return false
    end

    self:SetNWFloat("DBS_EconCooldown", now + cooldown)
    return true
end
