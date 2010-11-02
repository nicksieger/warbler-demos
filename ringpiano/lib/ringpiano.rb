require 'logger'
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

module RingPiano
  VERSION = "1.0.0"
  LOG = Logger.new(STDOUT)
  LOG.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
end

require 'ringpiano/server'
