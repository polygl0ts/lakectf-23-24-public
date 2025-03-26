const { SlashCommandBuilder } = require('discord.js');
const { State } = require("../index.js")
const { checkRole, updateRole} = require("../game_utilities.js")
const {n, xor} = require("../game_rules.json")
const { translate } = require("../translate.js")
module.exports = {

	async execute(interaction) {
		if(!checkRole(interaction, "xor")){
			return await interaction.reply({content: `This command is only available to the mystic people full of symbols`, 
				ephemeral: true});
		}
		new_state = 0
        const state = await State.findOne({ where: { name: interaction.user.username } });
		if (state && !xor.includes(state.state_1)){
			await interaction.reply({content: `${interaction.user.username}'s emotional state must be full of symbols`, 
				ephemeral: true});
		} else if (state){
			old_state = state.state_0
			new_state = ((old_state ^ state.state_1) % n)
            await State.update({ state_0: new_state, state_1: state.state_1 }, { where: { name: interaction.user.username } });
			// TODO update role
			updateRole(interaction, old_state, new_state)
            await interaction.reply({content: `That seems to have had an exoredinary effect`+`\nYour mind seems to be as follows: ${translate(new_state)}${translate(state.state_1)}`, 
				ephemeral: true});
		} else {
			await interaction.reply({content: `${interaction.user.username}'s therapy session could not be found. Did you start the therapy properly?`, 
				ephemeral: true});
		}
		if ( new_state == 127 ){
			await interaction.followUp({content: `:partying_face: :partying_face: Congratulations! Can you see the flag now? :partying_face: :partying_face:`, 
				ephemeral: true})
		} else {
			//await addState(interaction)
		}
	},
};