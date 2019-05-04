resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

files {
}



client_script {
	'client/main.lua',
	'GUI.lua',
	'config.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/main.lua',
}