--!strict

local DiscordLuau = require("../DiscordLuau")
local TOKEN = require("TOKEN")

local DiscordSettings = DiscordLuau.SettingsBuilder.new(TOKEN)
local DiscordClient = DiscordLuau.DiscordClient.new(DiscordSettings)

DiscordClient:connectAsync():after(function()
	print("We've connected to the Discord Websocket! 🚀")
end)