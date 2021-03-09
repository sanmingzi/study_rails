require 'rack'

class FilterLocalHost
  def initialize(app)
    @app = app
  end

  def call(env)
    puts 'FilterLocalHost'
    req = Rack::Request.new(env)
    # if '127.0.0.1' == req.ip || '::1' == req.ip
    if 'localhost' == req.ip || '::1' == req.ip
      puts 'refuse visit from localhost'
      [403, {}, '']
    else
      @app.call(env)
    end
  end
end

class UpcaseAll
  def initialize(app)
    @app = app
  end

  def call(env)
    puts 'UpcaseAll'
    status, headers, response = @app.call(env)
    # response.upcase!
    response.each(&:upcase!)
    [status, headers, response]
  end
end

class RackApp
  def call(env)
    puts 'RackApp'
    [200, {"Content-Type" => "text/plain"}, ["Hello from Rack"]]
  end
end

handler = Rack::Handler::Thin
app = Rack::Builder.new do |builder|
  builder.use FilterLocalHost
  builder.use UpcaseAll
  builder.run RackApp.new
end
handler.run app
