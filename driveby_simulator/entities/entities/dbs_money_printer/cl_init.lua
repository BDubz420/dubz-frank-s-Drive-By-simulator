include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local distSqr = ply:GetPos():DistToSqr(self:GetPos())
    if distSqr > (220 * 220) then return end

    local pos = self:GetPos() + self:GetUp() * 14
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    local stored = self:GetNWInt("DBS_PrinterStored", 0)
    local maxStored = math.max(1, self:GetNWInt("DBS_PrinterMax", 3000))
    local pct = math.Clamp(stored / maxStored, 0, 1)
    local nextTick = math.max(0, self:GetNWFloat("DBS_PrinterNextTick", CurTime()) - CurTime())

    cam.Start3D2D(pos, ang, 0.08)
        draw.RoundedBox(6, -140, -60, 280, 120, Color(15, 18, 22, 220))
        draw.SimpleText("Money Printer", "DermaLarge", 0, -45, Color(240, 240, 240), TEXT_ALIGN_CENTER)
        draw.SimpleText("Stored: $" .. string.Comma(stored), "DermaDefaultBold", 0, -14, Color(200, 230, 200), TEXT_ALIGN_CENTER)
        draw.RoundedBox(4, -110, 12, 220, 14, Color(40, 40, 45, 230))
        draw.RoundedBox(4, -110, 12, 220 * pct, 14, Color(70, 160, 85, 240))
        draw.SimpleText("Next print: " .. string.format("%.1fs", nextTick), "DermaDefault", 0, 34, Color(190, 190, 190), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
