ActionDispatch::Routing::RouteSet.new

ActionDispatch::Routing::RouteSet.instance_methods

```ruby
def instance_method_defined_in(name, c)
  ancestors = c.ancestors
  ancestors.select! { |ancestor| ancestor.instance_methods(false).include?(name) }
  puts "#{name} defined in #{ancestors.inspect}"
  ancestors
end
```

```ruby
ActionDispatch::Routing::RouteSet.instance_methods.grep /draw/
instance_method_defined_in(:draw, ActionDispatch::Routing::RouteSet)
# => [ActionDispatch::Routing::RouteSet]
```

```ruby
ActionDispatch::Routing::RouteSet.instance_methods.grep /call/
instance_method_defined_in(:call, ActionDispatch::Routing::RouteSet)
# => [ActionDispatch::Routing::RouteSet]

def call(env)
  req = make_request(env)
  req.path_info = Journey::Router::Utils.normalize_path(req.path_info)
  @router.serve(req)
  # Journey::Router.new @set
end

def initialize(config = DEFAULT_CONFIG)
  self.named_routes = NamedRouteCollection.new
  self.resources_path_names = self.class.default_resources_path_names
  self.default_url_options = {}
  self.draw_paths = []

  @config                     = config
  @append                     = []
  @prepend                    = []
  @disable_clear_and_finalize = false
  @finalized                  = false
  @env_key                    = "ROUTES_#{object_id}_SCRIPT_NAME"

  @set    = Journey::Routes.new
  @router = Journey::Router.new @set
  @formatter = Journey::Formatter.new self
  @polymorphic_mappings = {}
end
```

ActionDispatch::Routing::RouteSet.instance_methods.grep /eval_block/
instance_method_defined_in(:eval_block, ActionDispatch::Routing::RouteSet)

ActionDispatch::Routing::RouteSet.instance_methods.grep /root/
instance_method_defined_in(:root, ActionDispatch::Routing::RouteSet)

ActionDispatch::Routing::RouteSet.instance_methods.grep /resources/
instance_method_defined_in(:resources, ActionDispatch::Routing::RouteSet)

ActionDispatch::Routing::RouteSet.instance_methods.grep /resources/
instance_method_defined_in(:resources, ActionDispatch::Routing::RouteSet)


```ruby
# route_set.rb
def dispatch(controller, action, req, res)
  controller.dispatch(action, req, res)
end
```

```ruby
# dispatch
ApplicationController.instance_methods.grep /dispatch/
instance_method_defined_in(:dispatch, ApplicationController)

# [ActionController::Metal]
def dispatch(name, request, response) #:nodoc:
  set_request!(request)
  set_response!(response)
  process(name)
  request.commit_flash
  to_a
end
```

```ruby
# process
ApplicationController.instance_methods.grep /process/
instance_method_defined_in(:process, ApplicationController)
# [ActionView::Rendering, AbstractController::Base]

# AbstractController::Base
class << self
  def process(action, *args)
    @_action_name = action.to_s

    unless action_name = _find_action_name(@_action_name)
      raise ActionNotFound.new("The action '#{action}' could not be found for #{self.class.name}", self, action)
    end

    @_response_body = nil

    process_action(action_name, *args)
  end

  def process_action(method_name, *args)
    send_action(method_name, *args)
  end

  alias send_action send
end
```
