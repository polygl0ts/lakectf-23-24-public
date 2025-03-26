const { SlashCommandBuilder } = require('discord.js');
const { State } = require("../../index.js")
const { checkRole } = require("../../game_utilities.js")
module.exports = {
	data: new SlashCommandBuilder()
		.setName('stateof')
		.setDescription('Examine target\'s emotional state')
    	.addUserOption( option =>
			option.setName('target')
				.setDescription('player who\'s state to examine')
				.setRequired(true)
		),
	
	async execute(interaction) {
		const target = interaction.options.getUser('target');
        const state = await State.findOne({ where: { name: target.username } });
		//console.log(`stateof by ${interaction.user.username} on ${target.username}`)
		if (state){
			await interaction.reply({content: `${target.username}'s emotional state is ${state.state_0},${state.state_1}`, 
				ephemeral: true});
		} else {
			await interaction.reply({content: `${target.username}'s emotional state could not be found. Did they start properly?`, 
				ephemeral: true});
		}
	},
};