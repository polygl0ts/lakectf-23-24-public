// Todo given rolename and interacrtion, says 
const {role_names} = require("./game_rules.json")
function addRole(interaction, name){
    name = role_names[name]
    const player_role = interaction.guild.roles.cache.find(role => role.name == name);
    if(!player_role){
        console.log(`[WARNING] addRole called with invalid role ${name}`)
    }
	interaction.member.roles.add(player_role);
}

function removeRole(interaction, name){
    name = role_names[name]
    const player_role = interaction.guild.roles.cache.find(role => role.name == name);
    if(!player_role){
        console.log(`[WARNING] removeRole called with invalid role ${name}`)
    }
	interaction.member.roles.remove(player_role);
}
function checkRole(interaction, name){
    name = role_names[name]
    const player_role = interaction.member.roles.cache.find(role => role.name == name);
    return player_role != undefined
}

//const {n} = require("./game_rules.json")

const roles = ["incr", "mult", "neg", "xor", "flag"]
const data = require("./game_rules.json")
function updateRole(interaction, old_state, new_state){
    for(role of roles){
        allowed = data[role]
        //console.log(`${role} ${allowed.includes(old_state)} ${allowed.includes(new_state)}`)
        if (allowed.includes(old_state) && !allowed.includes(new_state)){
            removeRole(interaction, role)
        }
        if(!allowed.includes(old_state) && allowed.includes(new_state)){
            addRole(interaction, role)
        }
    }
   
}

function setRole(interaction, new_state){
    for(role of roles){
        allowed = data[role]
        if (allowed.includes(new_state)){
            addRole(interaction, role)
        } else {
            removeRole(interaction, role)
        }
    }
    
}

module.exports = {
    addRole: addRole,
    removeRole: removeRole,
    checkRole: checkRole,
    updateRole: updateRole,
    setRole: setRole
}