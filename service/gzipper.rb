# GZip service.
#
 
require 'zlib'
require 'pathname'
require 'tempfile'

class GZipper
  #bp_version "0.1.0"
  #bp_doc "A tool to compress and uncompress files using GZip."

  @@temp_id = 0

  def initialize(args)
    @temp_dir = args['temp_dir']
    @pid = args['clientPid']
  end

  def tempfile(filename, ext)
    @@temp_id += 1
    return Pathname.new(@temp_dir) + "gz#{@@temp_id}_#{@pid}_#{filename}#{ext}"
  end

  def compress(bp, args)
    begin
      # if args['level'] is from (-1..9) return args['level], otherwise return -1
      level = (-1..9).include?(args['level']) ? args['level'] : -1
      
      gzfile = tempfile(args['file'].basename, ".gz")

      Zlib::GzipWriter.open(gzfile, level) do |gz|
        gz.write open(args['file'], "rb") {|io| io.read }
        gz.close
      end
    
      bp.complete(gzfile)

    rescue Exception => err
      bp.error('Compress Error', err.message)
    end

  end
  
  #bp_doc :compress,   "Compress a file using GZip.
  #                    <file:path> The file to compress.
  #                    [level:integer] The optional compression level, 0-9."

  def uncompress(bp, args)
    begin
      tempfile = tempfile(args['file'].basename(".gz"), "")
      unzipped = File.open(tempfile, 'w')
      Zlib::GzipReader.open(args['file']) do |gz|
        unzipped.write gz.read
        gz.close
        unzipped.close
      end

      bp.complete(tempfile)

    rescue Exception => err
      bp.error('Uncompress Error', err.message)
    end

  end
    
  #bp_doc :uncompress,   "Uncompress a file using GZip.
  #                    <file:path> The file to uncompress."

end

rubyCoreletDefinition = {  
  'class' => "GZipper",  
  'name' => "GZipper",  
  'major_version' => 0,  
  'minor_version' => 1,  
  'micro_version' => 1,  
  'documentation' => 'A tool to compress and uncompress files using GZip.',
  'functions' =>  
  [  
    {  
      'name' => 'compress',  
      'documentation' => "Compress a file using GZip.",
      'arguments' => [  
        {  
          'name' => 'file',
          'type' => 'path',  
          'required' => true,
          'documentation' => 'The file to compress.'
        },
        {
          'name' => 'level',
          'type' => 'integer',
          'required' => 'false',
          'documentation' => 'Level of compress (def: -1, valid values 0-9).  Zero is no compression, 9 is best slowest but best compression.'
        }
      ]
    },
    
    {
      'name' => 'uncompress',
      'documentation' => "Uncompress a gzipped file.",
      'arguments' => [
        {  
          'name' => 'file',
          'type' => 'path',  
          'required' => true,
          'documentation' => 'The gzipped file to uncompress.'
        }
      ]
    }
  ]
}
