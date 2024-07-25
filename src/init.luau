--!strict

local DiscordLuau = require("../DiscordLuau")
local TOKEN = require("TOKEN")

local CommandCallbacks = {
	["Pin/Unpin message"] = require("CommandCallbacks/Pin")
}

local DiscordSettings = DiscordLuau.SettingsBuilder.new(TOKEN)
local DiscordClient = DiscordLuau.DiscordClient.new(DiscordSettings)

local EPHEMERAL_FLAG: number = bit32.lshift(1, 6)



DiscordClient.eventManager.onInteraction:connect(function(interaction)
	local callback = assert(CommandCallbacks[interaction.data.name], "Invalid command: " .. interaction.data.name)
	local messageContent = callback(interaction, DiscordClient)

	interaction:sendMessageAsync(DiscordLuau.MessageBuilder.new()
		:setContent(messageContent)
		:setFlags(EPHEMERAL_FLAG)
	)
end)

-- Autopin first message
DiscordClient.eventManager.onMessage:connect(function(message: DiscordLuau.DiscordMessage)
	if message.id ~= message.channelId then return end -- Make sure message is forum post

	message:pinAsync()
end)

DiscordClient.eventManager.onReady:connect(function()
	local pinCommand = DiscordLuau.CommandBuilder.new()
		:setName("Pin/Unpin message")
		:setType(DiscordLuau.CommandBuilder.Type.MessageContextAction)
		:addContext(DiscordLuau.CommandBuilder.Context.Guild)
		:addIntegration(DiscordLuau.CommandBuilder.IntegrationType.GuildCommand)

	DiscordClient.discordApplication:setSlashCommandsAsync({pinCommand}):await()
end)



DiscordClient:connectAsync()