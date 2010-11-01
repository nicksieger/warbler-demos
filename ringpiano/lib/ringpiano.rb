require 'logger'
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

module RingPiano
  LOG = Logger.new(STDOUT)
  LOG.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
end

require 'ringpiano/server'
