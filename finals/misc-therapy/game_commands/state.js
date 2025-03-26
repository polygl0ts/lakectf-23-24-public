const { SlashCommandBuilder } = require('discord.js');
const { State } = require("../index.js")
const { checkRole } = require("../game_utilities.js")
const {translate} = require("../translate.js")
module.exports = {

	async execute(interaction) {
		if(!checkRole(interaction, "player")){
			return await interaction.reply({content: `This command is only available to players. Did you start your therapy?`, 
				ephemeral: true});
		}
        const state = await State.findOne({ where: { name: interaction.user.username } });
		// console.log(`state for ${interaction.user.username} is ${state}`)
		if (state){
			await interaction.reply({content: `Your mind seems to be as follows: ${translate(state.state_0)}${translate(state.state_1)}`, 
				ephemeral: true});
		} else {
			await interaction.reply({content: `${interaction.user.username}'s therapy session could not be found. Did you start the therapy properly?`, 
				ephemeral: true});
		}
	},
	async addState(interaction) {
        const state = await State.findOne({ where: { name: interaction.user.username } });
		// console.log(`state for ${interaction.user.username} is ${state}`)
		if (state){
			await interaction.followUp({content: `Your mind seems to be as follows: ${translate(state.state_0)}${translate(state.state_1)}`, 
				ephemeral: true});
		} else {
			await interaction.followUp({content: `${interaction.user.username}'s therapy session could not be found. Did you start the therapy properly?`, 
				ephemeral: true});
		}
	},
};
