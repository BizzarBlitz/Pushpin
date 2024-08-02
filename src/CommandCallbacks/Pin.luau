--!strict

local DiscordLuau = require("../../DiscordLuau")

local MAX_PINNED: number = 50

return function(interaction: DiscordLuau.DiscordInteraction & {data: {[string]: any}}, client: DiscordLuau.DiscordClient): string
	-- interaction:deferAsync():after(function()
	
	local channelId = interaction.data.resolved.messages[interaction.data.targetId].channelId
	local channel = client:fetchChannelAsync(channelId):await() :: DiscordLuau.GuildPublicThreadChannel

	-- Make sure channel is thread
	local ownerId = channel.ownerId
	if not ownerId then
		return "This command can only be used in threads"
	end

	-- Make sure command user owns channel
	local cachedUser = interaction.discordClient.discordCache:getData("DiscordUser", ownerId)
	if not cachedUser then
		return "You must be the thread author to pin/unpin messages (no cache)"
	end

	local userId = cachedUser.id
	if userId ~= ownerId then
		return "You must be the thread author to pin/unpin messages"
	end

	local message = channel:getMessageAsync(interaction.data.targetId):await()
	
	-- Make sure message is able to be pinned
	if message.type ~= 0 and message.type ~= 19 then -- Normal or reply
		return "Message cannot be pinned"
	end

	-- Make sure pinned isn't maxxed out
	local pinnedMessages = channel:getPinnedMessagesAsync():await()

	if #pinnedMessages == MAX_PINNED then
		return `Channel has reached the pin limit of {MAX_PINNED} messages`
	end

	if message.pinned then
		-- Unpin message
		message:unpinAsync()
		return "Message unpinned"
	end
	
	-- Pin message
	message:pinAsync()
	return "Message pinned"
	-- end)
end