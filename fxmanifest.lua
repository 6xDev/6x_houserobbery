fx_version 'bodacious'
games { 'gta5' }
lua54 'yes'

author '6X Development'
description '[QB] 6x_houserobbery'
version '1.0.7'

client_scripts{
    "client/client.lua"
}

server_scripts {
    "server/server.lua"
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}
