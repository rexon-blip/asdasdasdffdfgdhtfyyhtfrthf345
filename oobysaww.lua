local ffi = require("ffi")

ffi.cdef[[
    int MessageBoxA(void* hWnd, const char* lpText, const char* lpCaption, unsigned int uType);
]]

-- Your custom message text and title
local message = "NIGGA" -- change this
local title = "HAIL HITLER" -- change this too

-- How many boxes you want to pop
local count = 10000

-- Spams message boxes
for i = 1, count do
    ffi.C.MessageBoxA(nil, message, title, 0)
end
