fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

name 'fivem_plane_spawn'
author 'nzkfc'
description 'Spawns a static cargoplane above LS with effects'
version '1.0'
repository 'https://github.com/nzkfc'

shared_script '@PolyZone/client.lua'

client_scripts {
    'client.lua'
}

dependencies {
    'PolyZone'
}