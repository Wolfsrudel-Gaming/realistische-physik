fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'wr_physics_vehicle'
description 'wr_physics - land vehicles: drivetrain simulation (phase 3a, v0)'
author 'Wolfsrudel Gaming'
version '0.1.0'
license 'GPL-3.0'

shared_scripts {
    -- core libraries (own copy of the WRP namespace, see core/client/main.lua)
    '@wr_physics_core/shared/lib/class.lua',
    '@wr_physics_core/shared/lib/wmath.lua',
    '@wr_physics_core/shared/lib/units.lua',
    '@wr_physics_core/shared/lib/curve.lua',
    '@wr_physics_core/shared/lib/vec.lua',
    '@wr_physics_core/shared/lib/deepmerge.lua',
    '@wr_physics_core/shared/log.lua',
    '@wr_physics_core/shared/config.lua',
    '@wr_physics_core/shared/locale.lua',
    '@wr_physics_core/shared/bridge/framework.lua',
    -- simulation
    'shared/sim/engine.lua',
    'shared/sim/gearbox.lua',
    'shared/sim/drivetrain.lua',
    'shared/sim/fuel.lua',
    'shared/sim/longitudinal.lua',
    -- datasheets
    'shared/specs/spec.lua',
    'shared/specs/classes.lua',
    'data/vehicles/*.lua',
    'shared/specs/registry.lua',
}

client_scripts {
    '@wr_physics_core/client/errors.lua',
    '@wr_physics_core/client/scheduler.lua',
    'client/input.lua',
    'client/coupling.lua',
    'client/vehicle.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'locales/*.json',
}

dependency 'wr_physics_core'
