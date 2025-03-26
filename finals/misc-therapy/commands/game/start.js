const { SlashCommandBuilder } = require('discord.js');
const { State } = require("../../index.js")
const { addRole, setRole } = require("../../game_utilities.js")
module.exports = {
	data: new SlashCommandBuilder()
		.setName('start')
		.setDescription('Starts a new therapy session'),
	async execute(interaction) {
		// interaction.user is the object representing the User who ran the command
		// interaction.member is the GuildMember object, which represents the user in the specific guild
		/*
		map = interaction.guild.roles.cache
		roles = ""
		for ( key, value of map){
			roles.concat(`${key}: ${}`)
		}
		*/
		//1228385803479027754(player)
		/*
		const player_role = interaction.guild.roles.cache.find(role => role.name == "player")
		interaction.member.roles.add(player_role);
		*/
		addRole(interaction, "player");
		setRole(interaction, 0)
		
		const [affectedRows, created] = await State.findOrCreate({ where: { name: interaction.user.username },defaults: { state_0: 0, state_1:0 }});
		if (!created){
			await interaction.reply({content: `With a new therapy session ${interaction.user.username}'s emotional state is reset`, ephemeral: true});
		} else {
			await interaction.reply({content: `${interaction.user.username} is primed to start with a fresh mind`, ephemeral: true});
		}

		/*
		
		
		// List of servers ? interaction.client.guilds.cache.entries()

		await interaction.reply(`${interaction.user.username} has started`);*/
	},
};
