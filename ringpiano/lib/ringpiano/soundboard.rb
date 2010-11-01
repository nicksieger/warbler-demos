require 'java'

module RingPiano
  class Soundboard
    attr_reader :name

    def initialize(server = nil)
      @server = server || Server.new
      synth = javax.sound.midi.MidiSystem.synthesizer
      synth.open
      @channel = synth.channels[0]
      register
      sound_loop
    end

    def register
      @server.register(:Soundboard, DRbObject.new(self), @server.name)
      LOG.info "Registered Soundboard: #{@server.name}"
    end

    def note_on(note, volume)
      LOG.debug "note on: #{note}"
      @channel.note_on note, volume
    end

    def note_off(note)
      LOG.debug "note off: #{note}"
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
end
