fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'wr_physics_core'
description 'wr_physics - core: physics library, config, bridges, scheduler, persistence'
author 'Wolfsrudel Gaming'
version '0.1.0'
repository 'https://github.com/wolfsrudel-gaming/realistische-physik'
license 'GPL-3.0'

shared_scripts {
    'shared/lib/class.lua',
    'shared/lib/wmath.lua',
    'shared/lib/units.lua',
    'shared/lib/curve.lua',
    'shared/lib/vec.lua',
    'shared/lib/deepmerge.lua',
    'shared/log.lua',
    'shared/config.lua',
    'shared/locale.lua',
    'shared/bridge/framework.lua',
}

client_scripts {
    'client/errors.lua',
    'client/scheduler.lua',
    'client/player.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/errors.lua',
    'server/db.lua',
    'server/main.lua',
}

files {
    'locales/*.json',
}

dependency 'oxmysql'
