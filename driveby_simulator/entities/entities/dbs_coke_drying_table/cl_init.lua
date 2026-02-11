include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    if ply:GetPos():DistToSqr(self:GetPos()) > (220 * 220) then return end

    local pos = self:GetPos() + self:GetUp() * 24
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(pos, ang, 0.08)
        draw.RoundedBox(6, -120, -40, 240, 80, Color(16, 18, 22, 220))
        draw.SimpleText("Coke Drying Table", "DermaLarge", 0, -24, Color(240, 240, 240), TEXT_ALIGN_CENTER)
        draw.SimpleText("Queued: " .. self:GetNWInt("DBS_CokeTableQueued", 0), "DermaDefaultBold", 0, 0, Color(230, 210, 140), TEXT_ALIGN_CENTER)
        draw.SimpleText("Dry ready: " .. self:GetNWInt("DBS_CokeTableDry", 0), "DermaDefaultBold", 0, 18, Color(190, 230, 255), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
