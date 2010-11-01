module RingPiano
  class Server
    attr_reader :piano

    def initialize
      load_piano_space
    end

    def name
      @name ||= begin
                  user = (require 'etc'; Etc.getlogin)
                  host = Socket.gethostname rescue "Unknown"
                  "#{user}@#{host}"
                end
    end

    def note_on(note, volume)
      LOG.debug "send note_on: #{note}"
      @piano.write(['ringpiano', 'note_on', note, volume])
    end

    def note_off(note)
      LOG.debug "send note_off: #{note}"
      @piano.write(['ringpiano', 'note_off', note, nil])
    end

    def next_command
      @piano.take(['ringpiano', nil, nil, nil])[1..3].tap do |cmd|
        LOG.debug "receive #{cmd.inspect}"
      end
    end

    def register(*args)
      @services ||= []
      service = [:name, *args]
      ring_finger.write(service, Rinda::SimpleRenewer.new)
      @services << service
    end

    def close
      @services.each do |service|
        ring_finger.take(service)
      end
    end

    private
    def start_ring_server
      ts = Rinda::TupleSpace.new
      @ring_server = Rinda::RingServer.new(ts)
      LOG.info "Started Ring server with primary: #{ts}"
    end

    def ring_finger
      return @ring_finger if @ring_finger
      require 'timeout' # JRuby does not raise 'RingNotFound', so we'll just timeout
      begin
        @ring_finger = Timeout::timeout(5) do
          Rinda::RingFinger.finger.lookup_ring_any
          Rinda::RingFinger.primary
        end
        Thread.new do
          @ring_finger.notify(nil, [:name, nil, nil, nil]).each do |event, tuple|
            if event == 'write'
              LOG.info "Registered service: #{tuple[1]} #{tuple[3]}"
            else
              LOG.info "Unregistered service: #{tuple[1]} #{tuple[3]}"
            end
          end
          DRb.thread.join
        end
        LOG.info "Using primary #{@ring_finger}"
      rescue Exception => e
        LOG.debug e
        raise if @ring_server
        start_ring_server
        retry
      end
      @ring_finger
    end

    def load_piano_space
      piano_tuple = ring_finger.read_all([:name, nil, nil, nil]).detect {|s| s[1] == :RingPiano }
      unless piano_tuple
        ts = Rinda::TupleSpace.new
        register(:RingPiano, ts, 'Ring Piano')
        piano_tuple = ring_finger.read([:name, :RingPiano, nil, nil])
      end
      LOG.info "Using ring piano #{piano_tuple[2]}"
      @piano = Rinda::TupleSpaceProxy.new(piano_tuple[2])
    end
  end
end
