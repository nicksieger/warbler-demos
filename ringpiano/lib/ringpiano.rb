require 'logger'
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

module RingPiano
  LOG = Logger.new(STDOUT)
end

require 'ringpiano/server'

if $0 == __FILE__
  server = RingPiano::Server.new
  if defined?(JRUBY_VERSION)
    RingPiano::Soundboard.new(server)
    RingPiano::Keyboard.new(server)
  end
  DRb.thread.join
end
