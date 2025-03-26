const { Events, EmbedBuilder, ButtonBuilder, ButtonStyle, ActionRowBuilder } = require('discord.js');
const { State } = require("../index.js") 
const { universe } = require("../translate.js")
const { incr, mult, neg, xor } = require("../game_rules.json")

// When the client is ready, run this code (only once).
// The distinction between `client: Client<boolean>` and `readyClient: Client<true>` is important for TypeScript developers.
// It makes some properties non-nullable.

const player_command_channel = "1228395966898503681"
const universe_channel = "1231763859803471892"
const faces_channel = "1235263343472808007"
const hands_channel = "1235296423382220832"
const flags_channel = "1235296352771248298"
const symbols_channel = "1235295787450237028"
async function clear_channel(channel)  {
	let fetched;
	do {
		fetched = await channel.messages.fetch({limit: 100});
		//message.channel.bulkDelete(fetched);
		channel.bulkDelete(fetched);
	}
	while(fetched.size >= 2);
}


const push_emote = '🫸'
const xor_emote = '➕'// '✖️'
const state_emote = '❔'
const mult_emote = '*️⃣'
const zero_emote =  '🫥'
const incr_emote = '⏭️'
const neg_emote = '☯️'
module.exports = {
	name: Events.ClientReady,
	once: true,
	async execute(client) {
		
		const uni_channel = client.channels.cache.get(universe_channel)
		curr_channel = uni_channel
		await clear_channel(curr_channel)
		universe(curr_channel)

		curr_channel = client.channels.cache.get(faces_channel)
		await clear_channel(curr_channel)
		universe(curr_channel, incr)

		curr_channel = client.channels.cache.get(hands_channel)
		await clear_channel(curr_channel)
		universe(curr_channel, mult)

		curr_channel = client.channels.cache.get(flags_channel)
		await clear_channel(curr_channel)
		universe(curr_channel, neg)

		curr_channel = client.channels.cache.get(symbols_channel)
		await clear_channel(curr_channel)
		universe(curr_channel, xor)

		const channel = client.channels.cache.get(player_command_channel)

		await clear_channel(channel)
		const joyousEmbed = new EmbedBuilder()
			.setColor(0x0099FF)
			.setTitle('Therapy session')
			.setDescription(
`\`\`\`You can always do ${state_emote}, ${zero_emote} and ${push_emote}
${incr_emote}, ${neg_emote}, ${xor_emote} and ${mult_emote} depend on your emotional state, with ${xor_emote} and ${mult_emote} needing your full focus\`\`\``)
		/*
			TODO
			.setURL('https://discord.js.org/')
			.setAuthor({ name: 'Some name', iconURL: 'https://i.imgur.com/AfFp7pu.png', url: 'https://discord.js.org' })
			.setDescription('Some description here')
			.setThumbnail('https://i.imgur.com/AfFp7pu.png')
			.addFields(
				{ name: 'Regular field title', value: 'Some value here' },
				{ name: '\u200B', value: '\u200B' },
				{ name: 'Inline field title', value: 'Some value here', inline: true },
				{ name: 'Inline field title', value: 'Some value here', inline: true },
			)
			.addFields({ name: 'Inline field title', value: 'Some value here', inline: true })
			.setImage('https://i.imgur.com/AfFp7pu.png')
			.setTimestamp()
			.setFooter({ text: 'Some footer text here', iconURL: 'https://i.imgur.com/AfFp7pu.png' });
			
		*/
		const state_button = new ButtonBuilder()
			.setCustomId('state')
			.setLabel(state_emote)
			.setStyle(ButtonStyle.Secondary);

		const zero_button = new ButtonBuilder()
			.setCustomId('zero')
			.setLabel(zero_emote)
			.setStyle(ButtonStyle.Secondary);

		const push_button = new ButtonBuilder()
			.setCustomId('push')
			.setLabel(push_emote)
			.setStyle(ButtonStyle.Secondary);

		const incr_button = new ButtonBuilder()
			.setCustomId('incr')
			.setLabel(incr_emote)
			.setStyle(ButtonStyle.Secondary);

		const neg_button = new ButtonBuilder()
			.setCustomId('neg')
			.setLabel(neg_emote)
			.setStyle(ButtonStyle.Secondary);

		const xor_button = new ButtonBuilder()
			.setCustomId('xor')
			.setLabel(xor_emote)
			.setStyle(ButtonStyle.Secondary);

		const mult_button = new ButtonBuilder()
			.setCustomId('mult')
			.setLabel(mult_emote)
			.setStyle(ButtonStyle.Secondary);

		const always_buttons = new ActionRowBuilder()
			.addComponents(state_button, zero_button, push_button)//, incr_button, neg_button, xor_button, mult_button)
		const cmd_buttons = new ActionRowBuilder()
			.addComponents(incr_button, neg_button, xor_button, mult_button)
		//console.log(`Collected ${mult_button} from ${button_row}`);
		const message = await channel.send({
			embeds: [joyousEmbed],
			components: [always_buttons, cmd_buttons],
		})

		await State.sync()//({ force: true })
		console.log(`Ready! Logged in as ${client.user.tag}`);
	},
};
