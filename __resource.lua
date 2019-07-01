resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Cargo Delivery'

version '1.0.4'

client_script {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'client/main.lua',
	'GUI.lua',
	'config.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/br.lua',
	'locales/en.lua',
	'config.lua',
	'server/main.lua',
}
