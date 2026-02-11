include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if ply:GetPos():DistToSqr(self:GetPos()) > (220 * 220) then return end

    local pos = self:GetPos() + self:GetUp() * 18
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    local supplies = self:GetNWInt("DBS_CokeProcessorSupplies", 0)
    local raw = self:GetNWInt("DBS_CokeProcessorRaw", 0)

    cam.Start3D2D(pos, ang, 0.08)
        draw.RoundedBox(6, -130, -52, 260, 104, Color(16, 18, 22, 220))
        draw.SimpleText("Coke Processor", "DermaLarge", 0, -32, Color(240, 240, 240), TEXT_ALIGN_CENTER)
        draw.SimpleText("Supplies loaded: " .. supplies, "DermaDefaultBold", 0, 0, Color(255, 230, 170), TEXT_ALIGN_CENTER)
        draw.SimpleText("Raw output: " .. raw, "DermaDefaultBold", 0, 20, Color(180, 220, 255), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
