fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'wr_physics_devtools'
description 'wr_physics - developer tools: telemetry overlay, measurement runs, spike commands'
author 'Wolfsrudel Gaming'
version '0.1.0'
license 'GPL-3.0'

shared_scripts {
    '@wr_physics_core/shared/lib/class.lua',
    '@wr_physics_core/shared/lib/wmath.lua',
    '@wr_physics_core/shared/lib/units.lua',
    '@wr_physics_core/shared/lib/curve.lua',
    '@wr_physics_core/shared/lib/vec.lua',
    '@wr_physics_core/shared/lib/deepmerge.lua',
    '@wr_physics_core/shared/log.lua',
    '@wr_physics_core/shared/config.lua',
    '@wr_physics_core/shared/bridge/framework.lua',
}

client_scripts {
    '@wr_physics_core/client/errors.lua',
    'client/overlay.lua',
    'client/measure.lua',
    'client/spikes.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
}

dependencies {
    'wr_physics_core',
    'wr_physics_vehicle',
}
