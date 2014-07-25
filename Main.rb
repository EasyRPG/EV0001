#!/usr/bin/ruby1.9.1

#
# EV0001 Bot - Copyright 2011 vgvgf
#
# Version: Map0001.EV0003
#
# Released under the following terms:
#
#	1. Puto el que lee esto.
#	2. Fuck you if you read this.
#
# NO WARRANTIES INCLUDED. IT'S NOT EVEN WARRANTED
# THAT THERE ARE NO WARRANTIES INCLUDED.
#

# Add current dir to path
$: << '.'

$DEBUG = false

# Load things
require 'socket'
require 'net/http'
require 'uri'
require 'digest/md5'
require 'fileutils'
require 'Tools'
require 'Log'
require 'BotLog'
require 'Bot'
require 'Users'
require 'ChannelLog'
require 'Channel'
require 'ChannelEasyrpg'
require 'ChannelRpgMakerEs'
require 'Services'
require 'Irc'
require 'OnlineRand'
require 'Random'

# Options
LOG_PATH = '../../easyrpg/public_html/irc/log/'
LOG_URL = 'http://easy-rpg.org/irc/log/'

SERVER = 'irc.freenode.net'
PORT = 6667
CHANNELS = [ChannelEasyrpg.new('easyrpg'), ChannelRpgMakerEs.new('rpgmaker.es')]
NICKS = ['EV0001', 'EV0002', 'EV0003', 'EV0004', 'EV0005', 'EV0006', 'EV0007', 'EV0008', 'EV0009']
PASS = ''

MAX_MSG_BYTES = 256
MAX_BYTES_PER_SEC = 512
BYTES_PER_SEC_PENALTY = 256

OWNERS = ['vgvgf!~vgvgf@unaffiliated/vgvgf', 'fdelapena!~fdelapena@unaffiliated/fdelapena']

# Start
FileUtils.mkdir_p("Data") if !File.directory?("Data")

$irc = Irc.new(SERVER, PORT)

$irc.thread = Thread.new {
	loop do
		$irc.gets
	end
}
$irc.thread.abort_on_exception = true

$bot = Bot.new

$services = Services.new

$last_error = nil

$resurrect = true

# Main loop
begin
	loop do
		break if !$irc.thread.alive?
		$irc.update
		$bot.update
		sleep(0.1)
	end
rescue
	$bot.log_error('FATAL', $!)
ensure
	$irc.socket.close rescue nil
	$irc.thread.kill rescue nil
	$bot.add_log('QUIT') rescue nil
	$bot.do_all_tasks rescue nil
	system('ruby1.9.1 Main.rb &') if $resurrect
end
