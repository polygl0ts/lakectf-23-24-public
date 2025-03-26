const { SlashCommandBuilder } = require('discord.js');

module.exports = {
	data: new SlashCommandBuilder()
		.setName('user')
		.setDescription('Provides information about the user.'),
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
		await interaction.reply(`This command was run by ${interaction.user.username} ${interaction.user.id} , who joined on ${interaction.member.joinedAt} has roles ${interaction.member.roles.cache.map(role => role)}.`);
	},
};
