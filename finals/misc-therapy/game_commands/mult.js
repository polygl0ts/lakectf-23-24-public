const { SlashCommandBuilder } = require('discord.js');
const { State } = require("../index.js")
const { checkRole, updateRole} = require("../game_utilities.js")
const {n, mult} = require("../game_rules.json")
const { translate } = require("../translate.js")
module.exports = {
	async execute(interaction) {
		if(!checkRole(interaction, "mult")){
			return await interaction.reply({content: `Your mind must be fully at hand for us to do this`, 
				ephemeral: true});
		}
        const state = await State.findOne({ where: { name: interaction.user.username } });
		if (state && !mult.includes(state.state_1)){
			await interaction.reply({content: `We can only do this if your mind is like :open_hands:, fully handy`, 
				ephemeral: true});
		} else if (state){
			old_state = state.state_0
			new_state = ((old_state * state.state_1) % n)
            await State.update({ state_0: new_state, state_1: state.state_1 }, { where: { name: interaction.user.username } });
			// TODO update role
			updateRole(interaction, old_state, new_state)
            await interaction.reply({content: `That seems to have had a handy effect`+`\nYour mind seems to be as follows: ${translate(new_state)}${translate(state.state_1)}`, 
				ephemeral: true});
		} else {
			await interaction.reply({content: `${interaction.user.username}'s therapy session could not be found. Did you start the therapy properly?`, 
				ephemeral: true});
		}
		//await addState(interaction)
		
	},
};