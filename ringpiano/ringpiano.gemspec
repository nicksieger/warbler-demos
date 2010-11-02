# -*- encoding: utf-8 ; mode: ruby -*-

Gem::Specification.new do |s|
  s.name              = 'ringpiano'
  s.version           = '1.0.0'
  s.date              = '2010-11-02'

  s.rubyforge_project = %q{caldersphere}

  s.summary     = "Distributed MIDI piano using Rinda and JRuby"
  s.description = "Distributed MIDI Piano example from RubyConf 2010."

  s.authors  = ["Nick Sieger"]
  s.email    = 'nick@nicksieger.com'
  s.homepage = 'http://github.com/nicksieger/ringpiano'
  s.require_paths = %w[lib]
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.executables = ["ringpiano"]
  s.default_executable = "ringpiano"

  # = MANIFEST =
  s.files = %w[
    LICENSE
    README.md
    Rakefile
    bin/ringpiano
    lib/ringpiano.rb
    lib/ringpiano/keyboard.rb
    lib/ringpiano/participantlist.rb
    lib/ringpiano/server.rb
    lib/ringpiano/soundboard.rb
    lib/ringpiano/swing.rb
    ringpiano.gemspec
  ]
  # = MANIFEST =

  s.test_files = []

  s.rubygems_version = %q{1.3.7}
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
