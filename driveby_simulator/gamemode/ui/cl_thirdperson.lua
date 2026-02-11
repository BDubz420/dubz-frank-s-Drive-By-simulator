if not CLIENT then return end

DBS = DBS or {}
DBS.UI = DBS.UI or {}
DBS.UI.ThirdPerson = DBS.UI.ThirdPerson or { Enabled = false, NextToggle = 0 }

local function ToggleThirdPerson()
    if CurTime() < (DBS.UI.ThirdPerson.NextToggle or 0) then return end
    DBS.UI.ThirdPerson.NextToggle = CurTime() + 0.35

    DBS.UI.ThirdPerson.Enabled = not DBS.UI.ThirdPerson.Enabled

    local msg = DBS.UI.ThirdPerson.Enabled and "Third person enabled." or "Third person disabled."
    chat.AddText(Color(80, 200, 255), "[DBS] ", color_white, msg)
end

hook.Add("PlayerButtonDown", "DBS.ToggleThirdPersonF1", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if button ~= KEY_F1 then return end
    ToggleThirdPerson()
end)

function GM:ShowHelp()
    ToggleThirdPerson()
    return true
end

hook.Add("CalcView", "DBS.ThirdPersonCalcView", function(ply, pos, ang, fov)
    if not DBS.UI.ThirdPerson.Enabled then return end
    if not IsValid(ply) then return end

    local target = pos - ang:Forward() * 95 + Vector(0, 0, 18)
    local tr = util.TraceHull({
        start = pos,
        endpos = target,
        mins = Vector(-6, -6, -6),
        maxs = Vector(6, 6, 6),
        filter = ply
    })

    return {
        fov = fov,
        drawviewer = true,
        origin = tr.HitPos,
        angles = ang
    }
end)
