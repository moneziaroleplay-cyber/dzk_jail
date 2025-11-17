fx_version 'cerulean'
game 'gta5'

author 'Dzk'
description 'Système de jail RP immersif'
version '1.0.0'

-- Scripts client et server
client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

-- UI
ui_page 'index.html'

files {
    'index.html',
    'style.css',
    'script.js',
    'sounds/prison_alarm.mp3',
    'sounds/prison_voice.mp3'
}
