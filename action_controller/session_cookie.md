# Session & Cookie

- [rails guide Session](https://guides.rubyonrails.org/action_controller_overview.html#session)
- [rails guide Cookie](https://guides.rubyonrails.org/action_controller_overview.html#cookies)
- [Cookie-阮一峰](https://www.gobeta.net/books/ruanyf-javascript-tutorial/bom/cookie/)

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

## Cookie

```
当浏览器向服务器发起请求，会收到一个 response。在这个 response 的头部有一个字段 Set-Cookie。

Set-Cookie:test_key=test_value

那么浏览器就会存储一个名为 test_key 的 cookie，其值为 test_value。
```
