fx_version 'cerulean'
game 'gta5'
author 'OfekAF'

shared_scripts {
    'config/sh_config.lua'
}
client_scripts {
	'client/*.lua'
}

server_scripts  {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

lua54 'yes'
