const { SlashCommandBuilder } = require('discord.js');
const { State } = require("../index.js")
const { checkRole, updateRole } = require("../game_utilities.js")
const { translate } = require("../translate.js")
module.exports = {
	async execute(interaction) {
		if(!checkRole(interaction, "player")){
			return await interaction.reply({content: `This command is only available to players. Did you start your therapy?`, 
				ephemeral: true});
		}
		const state = await State.findOne({ where: { name: interaction.user.username } });
		if (state){
			old_state = state.state_0
			new_state = 0
            await State.update({ state_0: new_state, state_1: state.state_1 }, { where: { name: interaction.user.username } });
			// TODO update role
			updateRole(interaction, old_state, new_state)

            await interaction.reply({content: `Back to our roots I see`+`\nYour mind seems to be as follows: ${translate(new_state)}${translate(state.state_1)}`, 
				ephemeral: true});
		} else {
			await interaction.reply({content: `${interaction.user.username}'s therapy session could not be found. Did you start the therapy properly?`, 
				ephemeral: true});
		}
		//await addState(interaction)
		
	},
};
