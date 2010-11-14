require 'warbler'
jar = Warbler::Jar.new
jar.files["directory"] = nil # directory entry
jar.files["inline.txt"] = StringIO.new("in memory")
jar.files["path/a.txt"] = "a.txt" # disk file
jar.create("sample.jar")
