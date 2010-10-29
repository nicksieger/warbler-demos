#!/usr/bin/env ruby -w
# ringserver.rb
# Rinda RingServer

require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

ts = Rinda::TupleSpace.new
place = Rinda::RingServer.new(ts)

provider = Rinda::RingProvider.new :TupleSpace, ts, 'Tuple Space'
provider.provide

DRb.thread.join

