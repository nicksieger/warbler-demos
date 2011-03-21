# RubyConf 2010 Warbler demos

These demos were shown at my talk on Warbler at RubyConf 2010. You can
view the slides of the talk here:

http://www.slideshare.net/nicksieger/warbler-at-rubyconf-2010

## Preparation

Warbler 1.3.0 is needed to run these demos. Until 1.3.0 final is
available, you can use the pre-release:

$ gem install warbler --pre

## Running

After installing Warbler, simply run `warble` in each directory. In
both cases an executable .jar file should be created.

## Demos

Run each of the jars created by `warble` simply by running them with
`java -jar`. In the case of the Ring Piano GUI app you can also
double-click the file in the Windows Explorer or Mac OS X Finder to
launch it.

### Ring Piano

This is a GUI application using Ruby, DRb, Rinda, and Java's Swing and
MIDI APIs via JRuby's Java integration. You should be able to run
multiple copies of the Ringpiano app on your local network and play a
distributed piano!

### Rails 3.0.1

This is an example of packaging Rails itself into a jar file. You can
even use the jar file to generate a new Rails application without any
Ruby installed (even JRuby).

Currently this demo *almost* works -- you can run `rails --help` but
without the unpacked gems available, it can't actually generate an
application.

Of course you'll probably need Ruby or JRuby installed in order to
actually work on the Rails app...

### Jar

This is just a simple Ruby script demonstrating the `Warbler::Jar` API
for creating archives from Ruby. Run with `jruby jar.rb` after
installing Warbler.

### Littleapp

This is another Warbler jar example that creates a simple rack
application and serves it with Trinidad as an executable ruby jar.
