require 'java'
require 'logger'
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

module RingPiano
  LOG = Logger.new(STDOUT)

  class Server
    attr_reader :space

    def initialize
      load_piano_space
    end

    def note_on(note, volume)
      @piano.write(['ringpiano', 'note_on', note, volume])
    end

    def note_off(note)
      @piano.write(['ringpiano', 'note_off', note, nil])
    end

    def next_command
      @piano.take(['ringpiano', nil, nil, nil])[1..3]
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
      @ring_server = Rinda::RingServer.new(Rinda::TupleSpace.new)
      LOG.info "Started Ring server: #@ring_server"
    end

    def ring_finger
      return @ring_finger if @ring_finger
      require 'timeout' # JRuby does not raise 'RingNotFound', so we'll just timeout
      begin
        @ring_finger = Timeout::timeout(5) do
          Rinda::RingFinger.finger.lookup_ring_any
          Rinda::RingFinger.primary
        end
        LOG.info "Using #{@ring_finger}"
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
        LOG.info "Registered Ring Piano TupleSpace: #{ts}"
        piano_tuple = ring_finger.read([:name, :RingPiano, nil, nil])
      end
      LOG.info "Using #{piano_tuple[2]}"
      @piano = Rinda::TupleSpaceProxy.new(piano_tuple[2])
    end
  end

  java_import javax.sound.midi.MidiSystem

  class Soundboard
    def initialize(server)
      @server = server || Server.new
      synth = MidiSystem.synthesizer
      synth.open
      @channel = synth.channels[0]
      register
      sound_loop
    end

    def register
      user = (require 'etc'; Etc.getlogin)
      host = Socket.gethostname rescue "Unknown"
      @server.register(:Soundboard, DRbObject.new(self), "#{user}@#{host}")
      LOG.info "Registered Soundboard: #{self}"
    end

    def note_on(note, volume)
      @channel.note_on note, volume
    end

    def note_off(note)
      @channel.note_off note
    end

    def sound_loop
      Thread.new do
        loop do
          command = @server.next_command
          case command.first
          when 'note_on'
            note_on *command[1..2]
          when 'note_off'
            note_off command[1]
          end
        end
      end
    end
  end

  java_import java.awt.event.KeyEvent

  class Keyboard
    include java.awt.event.KeyListener, java.awt.event.WindowListener

    NOTES = {
        KeyEvent::VK_G => 55,
        KeyEvent::VK_A => 57,
        KeyEvent::VK_B => 59,
        KeyEvent::VK_C => 60,
        KeyEvent::VK_D => 62,
        KeyEvent::VK_E => 64,
        KeyEvent::VK_F => 65
      }

    def initialize(server)
      @server = server || Server.new
      @adjust = 0
      @frame = javax.swing.JFrame.new "Ring Piano"
      @frame.set_size 400, 100
      @frame.layout = java.awt.FlowLayout.new
      @frame.add javax.swing.JLabel.new("Type using A-G keys. Use SHIFT for sharps and CTRL for flats.")
      @frame.add_key_listener(self)
      @frame.add_window_listener(self)
      @frame.default_close_operation = @frame.class::EXIT_ON_CLOSE
      @frame.visible = true
      @notes = {}
    end

    def key_to_note(code)
      @adjust + NOTES[code] if NOTES[code]
    end

    def keyPressed(event)
      case event.key_code
      when KeyEvent::VK_SHIFT
        @adjust = 1
      when KeyEvent::VK_CONTROL, KeyEvent::VK_ALT
        @adjust = -1
      else
        return if @notes.include?(event.key_code)
        note = key_to_note(event.key_code)
        @notes[event.key_code] = note
        @server.note_on(note, 99) if note
      end
    end

    def keyReleased(event)
      case event.key_code
      when KeyEvent::VK_SHIFT, KeyEvent::VK_CONTROL, KeyEvent::VK_ALT
        @adjust = 0
      else
        note = @notes.delete(event.key_code) || key_to_note(event.key_code)
        @server.note_off(note) if note
      end
    end

    def windowClosing(*)
      MidiSystem.synthesizer.close
      @server.close
    end

    def method_missing(*)
      # for omitted interface methods
    end
  end
end

if $0 == __FILE__
  server = RingPiano::Server.new
  RingPiano::Soundboard.new(server)
  RingPiano::Keyboard.new(server)
end
