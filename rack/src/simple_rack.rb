require 'rack'

handler = Rack::Handler::Thin

class RackApp
  def call(env)
    puts '----------------------------------'
    req = Rack::Request.new(env)
    puts req.path_info
    puts req.ip
    puts req.user_agent
    puts req.request_method
    puts req.body
    puts req.media_type
    [200, {"Content-Type" => "text/plain"}, "Hello from Rack"]
  end
end

handler.run RackApp.new
