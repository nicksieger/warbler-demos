RingPiano
=========

http://github.com/nicksieger/ringpiano

## Description

An example featuring JRuby to build a distributed piano using Rinda,
Swing and javax.sound.midi APIs.

This example was built to showcase packaging a Ruby application as a
Java jar file. To see this in action, install Warbler and type
`warble` to create a jar file that can be run with `java -jar`.

## Requirements

- JRuby-only for the keyboard and soundboard. This Ruby code uses
  JRuby's Java integration to call the Swing and javax.sound APIs.
- Other rubies can run the tuplespace server or run the console to
  interact with the tuplespace and send note_on/note_off commands to
  remote soundboards.

## Install

      gem install ringpiano

## Run

RingPiano consists of several components: a server, a soundboard, a
keyboard, and a console.  `ringpiano <component>` runs the requested
component. `ringpiano` alone will run the server, soundboard and
keyboard.

When RingPiano starts up, it will attempt to locate a
Rinda::RingServer broadcasting UDP on the local network. If it does
not find one within five seconds, it will start one up.

On JRuby, the server component also will display a participant list
window showing all the local and remote components participating in
the RingPiano.

## Give back

I'll gladly accept [pull requests][pr] and [bug reports][issues].

[pr]: http://github.com/nicksieger/ringpiano/pulls
[issues]: http://github.com/nicksieger/ringpiano/issues
