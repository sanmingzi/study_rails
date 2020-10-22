# Session & Cookie

- [Session](https://guides.rubyonrails.org/action_controller_overview.html#session)
- [Cookie](https://guides.rubyonrails.org/action_controller_overview.html#cookies)

## Accessing the Session

```ruby
class ApplicationController < ActionController::Base
 
  private

  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end
end

class LoginsController < ApplicationController
  def create
    if user = User.authenticate(params[:username], params[:password])
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end

  def destroy
    session.delete(:current_user_id)
    @_current_user = nil
    redirect_to root_url
  end
end
```

## Flash Message

```
Flash message 是 Rails 中一种比较特别的 session。我们通常会使用 flash 来传递一些弹窗消息。
```

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "You have successfully logged out."
    redirect_to root_url
  end
end

<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```
