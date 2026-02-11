if not CLIENT then return end

net.Receive("DBS_Court_WaitSentence", function()
    local mins = net.ReadUInt(8)
    local wait = net.ReadUInt(8)

    chat.AddText(Color(80, 200, 255), "[DBS] ", color_white,
        "You are before the judge. Sentencing in " .. wait .. "s (" .. mins .. " min expected).")
end)
