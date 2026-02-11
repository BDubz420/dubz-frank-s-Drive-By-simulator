include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if ply:GetPos():DistToSqr(self:GetPos()) > (220 * 220) then return end

    local pos = self:GetPos() + self:GetUp() * 20
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(pos, ang, 0.08)
        draw.RoundedBox(6, -120, -30, 240, 60, Color(16, 18, 22, 220))
        draw.SimpleText("Coke Brick Packer", "DermaLarge", 0, -8, Color(240, 240, 240), TEXT_ALIGN_CENTER)
        draw.SimpleText("Insert dried coke nearby and press E", "DermaDefaultBold", 0, 14, Color(180, 220, 255), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
