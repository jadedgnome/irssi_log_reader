require "logs"


before do
  @log_list = Logs.from_folder(options.irc_logs_path)
end


get "/" do 
  haml :"browse/index"
end

get %r{^/browse/?} do
  redirect "/"
end

# /server
get %r{^/browse/([^/]+)/?$} do |server|
  @server = @log_list[server]
  if @server.nil?
    haml :missing
  else
    haml :"browse/server"
  end
end

#need regex'd routes because sinatra hates escaped #'s in the url
# /server/#chatroom
get %r{^/browse/([^/]+)/([^/]+)/?$} do |server, chatroom|
  @server = @log_list[server]
  if @server
    @chatroom = @server[chatroom]
    if@chatroom
      return haml :"browse/chatroom"
    end
  end
  haml :missing
end

# /server/#chatroom/date
get %r{^/browse/([^/]+)/([^/]+)/([^/]+)/?$} do |server, chatroom, date|

  if @server = @log_list[server]
    if @chatroom = @server[chatroom]
      if @logfile = @chatroom[date]
        return haml :"browse/logfile"
      end
    end
  end
  haml :missing
end