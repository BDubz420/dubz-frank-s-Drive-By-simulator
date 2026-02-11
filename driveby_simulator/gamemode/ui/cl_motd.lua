if not CLIENT then return end

local MOTD_FRAME

net.Receive("DBS_MOTD_Show", function()
    if IsValid(MOTD_FRAME) then MOTD_FRAME:Remove() end

    MOTD_FRAME = vgui.Create("DFrame")
    MOTD_FRAME:SetSize(760, 560)
    MOTD_FRAME:Center()
    MOTD_FRAME:SetTitle("")
    MOTD_FRAME:MakePopup()
    MOTD_FRAME.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(12, 12, 16, 245))
        draw.RoundedBox(12, 0, 0, w, 54, Color(20, 24, 30, 250))
        draw.SimpleText("Welcome to DriveBy Simulator", "DBS_UI_Title", 16, 16, color_white, TEXT_ALIGN_LEFT)
    end

    local html = vgui.Create("DHTML", MOTD_FRAME)
    html:Dock(FILL)
    html:DockMargin(12, 64, 12, 12)
    html:SetHTML([[<!doctype html><html><body style="margin:0;background:#0f1116;color:#f2f2f2;font-family:Arial;padding:16px;">
        <div style="text-align:center;margin-bottom:14px;"><img src="https://i.imgur.com/TCs76vH.png" style="max-height:120px;"></div>
        <h2 style="margin:0 0 10px 0;">How to play</h2>
        <ul style="line-height:1.7;font-size:15px;">
            <li>Pick a team by using Jerome (team NPC).</li>
            <li>Use F2 on doors to buy/sell property.</li>
            <li>Use Eli dealers for utilities and weapons.</li>
            <li>Use car dealer for buying, customizing, and auctioning vehicles.</li>
            <li>Train at Vinny for pickpocket + lockpick upgrades.</li>
            <li>Type !red, !blue, or !police in chat to switch teams any time.</li>
        </ul>
    </body></html>]])
end)
