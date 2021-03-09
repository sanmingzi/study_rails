# use 'rackup' to run this file

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
    puts [status, headers, response].inspect
    response.each(&:upcase!)
    [status, headers, response]
  end
end

app = -> (env) {
  puts 'app'
  [200, {"Content-Type" => "text/plain"}, ["Hello from Rack"]]
}

use FilterLocalHost
use UpcaseAll
run app
