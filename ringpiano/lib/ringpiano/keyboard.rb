require 'java'

module RingPiano
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

    def initialize(server = nil)
      @server = server || Server.new
      @adjust = 0
      @note_player = java.util.concurrent.Executors.newCachedThreadPool
      java.awt.EventQueue.invokeAndWait do
        @frame = javax.swing.JFrame.new "Ring Piano"
        @frame.set_size 400, 100
        @frame.layout = java.awt.FlowLayout.new
        @frame.add javax.swing.JLabel.new("Type using A-G keys. Use SHIFT for sharps and CTRL for flats.")
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
      LOG.info "Registered Keyboard: #{@server.name}"
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

    def windowClosing(*)
      javax.sound.midi.MidiSystem.synthesizer.close
      @server.close
    end

    def method_missing(*)
      # for omitted interface methods
    end
  end
end
