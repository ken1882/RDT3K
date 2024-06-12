require 'discordrb'
require 'dotenv'
require 'json'
require 'fileutils'
Dotenv.load

require_relative 'utils'

bot_token = ENV['DC_BOT_TOKEN']
client_id = ENV['DC_CLIENT_ID']

$bot = Discordrb::Bot.new(
    token: bot_token,
    client_id: client_id
)

$bot.run(:async)