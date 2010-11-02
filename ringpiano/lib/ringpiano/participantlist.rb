require 'ringpiano/swing'

module RingPiano
  class ParticipantList
    include Application
    include java.awt.event.WindowListener

    class ServiceList < javax.swing.AbstractListModel
      def initialize
        super()
        @services = []
      end

      def getElementAt(i)
        @services[i]
      end

      def getSize
        @services.length
      end

      def update(new_services)
        services = @services
        if new_services.length > @services.length
          diff = new_services - @services
        else
          diff = @services - new_services
        end
        @services = new_services
        diff.each do |item|
          if new_services.include?(item) # add
            index = new_services.index(item)
            fireIntervalAdded(self, index, index)
          else                           # remove
            index = services.index(item)
            fireIntervalRemoved(self, index, index + 1)
          end
        end
      end
    end

    def initialize(server = nil)
      @server = server || RingPiano::Server.new
      @server.listeners << self
      @model = ServiceList.new
      notify
      java.awt.EventQueue.invokeAndWait do
        @frame = javax.swing.JFrame.new "Participants"
        @frame.set_size 300, 200
        @frame.add javax.swing.JScrollPane.new.tap {|js| js.viewport.view = javax.swing.JList.new(@model) }
        @frame.add_window_listener(self)
        @frame.default_close_operation = @frame.class::EXIT_ON_CLOSE
        @frame.visible = true
      end
    end

    def notify(*)
      @model.update(@server.primary.read_all([:name, nil, nil, nil]).map {|tuple| "#{tuple[1]} #{tuple[3]}"})
    end

    def windowClosing(*)
      close
    end

    def close
      @server.close
    end

    def method_missing(*)
      # for omitted interface methods
    end
  end
end
