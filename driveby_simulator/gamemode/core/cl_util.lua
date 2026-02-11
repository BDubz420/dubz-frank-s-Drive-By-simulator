net.Receive("DBS_Notify", function()
    local msg = net.ReadString()
    chat.AddText(Color(80, 200, 255), "[DBS] ", color_white, msg)
end)