require 'java'
require 'ringpiano/swing'

module RingPiano
  class Keyboard
    include Application
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

    KEYS = {67 => 'g', 68 => 'g#', 69 => 'a', 70 => 'b-',
      71 => 'b', 72 => 'c', 73 => 'c#', 74 => 'd',
      75 => 'e-', 76 => 'e', 77 => 'f', 78 => 'f#', 79 => 'g'}

    def initialize(server = nil)
      super()
      @server = server || Server.new
      @adjust = 0
      @note_player = java.util.concurrent.Executors.newCachedThreadPool
      java.awt.EventQueue.invokeAndWait do
        @frame = javax.swing.JFrame.new "Ring Piano"
        @frame.set_size 430, 150
        @frame.layout = java.awt.FlowLayout.new
        KEYS.each do |value, note|
          button = javax.swing.JButton.new note
          button.add_action_listener do |e|
            LOG.debug "button pressed: #{note}"
            @note_player.submit { @server.note_on(value, 99) }
          end
          button.add_key_listener(self)
          @frame.add button
        end
        @frame.add javax.swing.JLabel.new("Or type using A-G keys. Use SHIFT for sharps and CTRL for flats.")
        @frame.add_key_listener(self)
        @frame.add_window_listener(self)
        @frame.default_close_operation = @frame.class::EXIT_ON_CLOSE
        @frame.visible = true
      end
      register
      @notes = {}
    end

    def register
      @server.register(:Keyboard, DRbObject.new(self), @server.name)
    end

    def key_to_note(event)
      if value = NOTES[event.key_code]
        value + (event.shift_down? ? 1 : (event.control_down? ? -1 : 0))
      end
    end

    def keyPressed(event)
      LOG.debug "key pressed: #{event}"
      return if @notes.include?(event.key_code)
      if note = key_to_note(event)
        @notes[event.key_code] = note
        @note_player.submit { @server.note_on(note, 99) }
      end
    end

    def keyReleased(event)
      LOG.debug "key released: #{event}"
      note = @notes.delete(event.key_code)
      @note_player.submit { @server.note_off(note) } if note
    end

    def close
      javax.sound.midi.MidiSystem.synthesizer.close
      @server.close
    end

    def windowClosing(*)
      close
    end

    def method_missing(*)
      # for omitted interface methods
    end
  end
end
