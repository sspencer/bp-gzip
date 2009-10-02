# Test gzipper from the command line to prove to yourself that
# gzipper works in theory.  From this directory:
#   $ ruby test.rb
#
# This file is NOT required for the service to run, though it
# is copied onto the Corelets directory via ServiceInstaller.

require 'gzipper.rb'
require 'pp'


def bp_log(level, msg)
  puts "LOG(#{level}): #{msg}"
end

def bp_version(ver)
  puts "VERSION #{ver}"
end

def bp_doc(method, doc)
  puts "#{method}: #{doc}"
end

class BPProxy
  def complete(val)
    puts "COMPLETE: #{val.pretty_inspect}"
  end
  
  def error(error, verbose)
    puts "ERROR: #{error}: #{verbose}"
  end
end
 
 
puts "==== START ===="
bp = BPProxy.new

# write a tmp file that we're going to compress
t = Tempfile.new("test")
t.write("hello\nhello there\nbye\nbye there\nhello\nhello there\nbye\nbye there\nhello\nhello there")
t.close

zipper = GZipper.new({'temp_dir'=>"/tmp/", 'clientPid' => Process.pid})
#zipper.compress(bp, {'file'=> t.path})
zipper.uncompress(bp, {'file' => Pathname.new("/tmp/ruby.rb.gz")})
sleep 1
puts "==== DONE ===="
