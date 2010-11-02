require 'java'

module RingPiano
  module Application
    if ENV_JAVA['java.vendor'] =~ /Apple/
      # set some mac-specific properties
      java.lang.System.setProperty "apple.awt.graphics.EnableQ2DX", "true"
      java.lang.System.setProperty "apple.laf.useScreenMenuBar", "true"
      java.lang.System.setProperty "com.apple.mrj.application.apple.menu.about.name", "Ring Piano"
      include com.apple.eawt.ApplicationListener

      def initialize
        Java::com.apple.eawt.Application.application.add_application_listener(self)
      end

      def handleQuit(*)
        close
        java.lang.System.exit(0)
      end
    end
  end

  java_import java.awt.event.KeyEvent
end
