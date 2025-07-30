fx_version 'cerulean'
game 'gta5'

author 'h4rp3r32'
description 'Staff Chat (/sc) command for staff communication'
version '1.0.0'

server_script 'server.lua'
client_script 'client.lua'

-- Add dependency to make sure staff_commands loads first
dependency 'staff_commands'
