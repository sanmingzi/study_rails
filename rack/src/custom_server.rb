require 'socket'
require 'rack'
require 'rack/lobster'

# https://github.com/rack/rack/blob/master/lib/rack/lobster.rb
app = Rack::Lobster.new
server = TCPServer.new 5678

#1
while session = server.accept
  request = session.gets
  puts request

  #2
  method, full_path = request.split(' ')
  path, query = full_path.split('?')

  #3
  status, headers, body = app.call({
    'REQUEST_METHOD' => method,
    'PATH_INFO' => path,
    'QUERY_STRING' => query
  })

  #4
  session.print "HTTP/1.1 #{status}\r\n"
  headers.each do |key, value|
    session.print "#{key}: #{value}\r\n"
  end
  session.print "\r\n"
  body.each do |part|
    session.print part
  end
  session.close
end
