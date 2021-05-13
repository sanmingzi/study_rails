# Controller

- [rails guide action_controller](https://guides.rubyonrails.org/action_controller_overview.html)

```bash
bundle exec rails generate controller users
bundle exec rails destroy controller users
```

## 命名规范

复数命名：ClientsController / SiteAdminsController 。但也不绝对是的，比如 ApplicationController

## Parameters

```ruby
# Array
GET /clients?ids[]=1&ids[]=2&ids[]=3
params[:ids]
```

```ruby
# Hash
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
params[:client]
```

```ruby
# Routing Parameters
get '/clients/:status', to: 'clients#index', foo: 'bar'
URL: /clients/active
params[:status]
```

- default_url_options

TODO

- Strong Parameters

TODO

## Session & Cookie

[Session & Cookie](session_cookie.md)

## Rendering XML and JSON

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.js   # index.js.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

## Filters

- before filter

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_login_url # halts request cycle
    end
  end
end

class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

- after filter

```
after filter 只会在 action 执行成功后触发，而不会在触发了 exception 后触发。
实际上，after filter 并不能改变 response。
所以 after filter 使用场景比较少。
```

- around filter

TODO

## Request Forgery Protection

```
form_authenticity_token
```

## Streaming and File Download

```ruby
send_data
send_file
```

## Rescue

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private

    def user_not_authorized
      flash[:error] = "You don't have access to this section."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  before_action :check_authorization

  def edit
    @client = Client.find(params[:id])
  end

  private

    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

```
生产环境下面的 ActiveRecord::RecordNotFound 默认跳转到 404 页面。当然你也可以自定义。
```
