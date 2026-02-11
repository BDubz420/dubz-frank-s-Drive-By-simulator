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

    local stored = self:GetNWInt("DBS_CokePrinterStored", 0)

    cam.Start3D2D(pos, ang, 0.08)
        draw.RoundedBox(6, -120, -44, 240, 88, Color(16, 18, 22, 220))
        draw.SimpleText("Coke Printer", "DermaLarge", 0, -30, Color(240, 240, 240), TEXT_ALIGN_CENTER)
        draw.SimpleText("Bricks ready: " .. stored, "DermaDefaultBold", 0, 6, Color(220, 230, 255), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
