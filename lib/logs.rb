# encoding: utf-8
require "list_tools"
require "cgi"

module Logs
  def self.from_folder(folder)
    return nil unless filelist = read_folder_from_filesystem(folder)
    
    build_objects(folder, filelist)
  end
  
  class LogList < Array
    def [](*args)
      if args.first.is_a? String
        self.find {|v| v.name == args.first }
      else
        super(*args)
      end
    end
    
  end
  
  class Server < LogList # array of <Chatroom>
    def initialize(name, *args)
      @name = name
      super(*args)
    end
    
    def name
      @name
    end
  end
  
  class Chatroom < LogList # array of <LogFile>
    def initialize(name, *args)
      @name = name
      super(*args)
    end
    
    def name
      @name
    end
    
    def private?
      !(name =~ /^#/)
    end
  end
  
  class LogFile #proxy to file object with lazy loading
    def initialize(name, path_with_filename)
      @name = name
      @path = path_with_filename
    end
    
    def name
      @name
    end
    
    def path
      @path
    end
    
    def safe_read(charset="UTF-8")
      to_file.read.encode(charset, :invalid => :replace, :undef => :replace, :universal_newline => true)
    end
    
    def to_file
      @file ||= File.open(@path).set_encoding(:binary)
    end
    
    def method_missing(*args)
      to_file.send(*args)
    end
  end
  
  
  private
  def self.read_folder_from_filesystem(folder)
    extract_filelist(folder)
  end
  
  def self.build_objects(folder, filelist)
    arr = LogList.new
    filelist.select{|v| v != '.'}.each do |server, chatrooms|
      srv = Server.new(server) # TYPEERROR HERE
      
      chatrooms.select{|v| v != '.'}.each do |chatroom, logs|
        cht = Chatroom.new(chatroom)
        
        logs['.'].each do |filename|
          name = filename.gsub(%r{.*?(\d{8})\.log}, '\\1')
          cht << LogFile.new(name, File.join(folder, server, chatroom, filename))
        end
        
        srv << cht unless cht.empty?
      end #chatrooms
      
      arr << srv
    end #filelist
    arr
  end
end