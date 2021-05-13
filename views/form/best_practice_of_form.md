# best practice of form

- [avoid field_with_errors](https://stackoverflow.com/questions/5267998/rails-3-field-with-errors-wrapper-changes-the-page-appearance-how-to-avoid-t)
- [validation with error messages](https://itnext.io/form-validation-with-error-messages-in-ruby-on-rails-cec36ba3daa9)

## avoid field_with_errors

```ruby
# config/application.rb

config.action_view.field_error_proc = Proc.new { |html_tag, instance|
  html_tag
}
```

在默认情况下，如果 model validation 出错的话，rails 会自动给 html tag 加上一个 div。有时候正是加了这个 div，可能会导致我们的页面样式出错，所以我们可以在 application.rb 中重写这个方法，将该功能禁用掉。

```ruby
# 默认添加了 div

@@field_error_proc = Proc.new{ |html_tag, instance|
  "<div class=\"field_with_errors\">#{html_tag}</div>".html_safe
}
```

## form_helper

```ruby
# app/helpers/form_helper.rb

module FormHelper
  def form_group_for(form, field, opts={}, &block)
    object = form.object

    value         = object[field]
    is_invalid    = object.errors[field].present?
    error_message = object.errors[field].try(:first)

    label       = opts.fetch(:label) { true }
    label_text  = opts.fetch(:label_text) { nil }
    placeholder = opts.fetch(:placeholder) { '' }

    content_tag :div, class: "form-group" do
      concat form.label(field, label_text, class: 'control-label') if label
      if block_given?
        yield
      else
        concat form.text_field(field, value: value, class: "form-control #{'is-invalid' if is_invalid }", placeholder: placeholder)
      end
      concat content_tag(:div, error_message, class: 'invalid-feedback')
    end
  end
end
```

```ruby
<%= form_with(model: role) do |f| %>
  <%= form_group_for(f, :name, label_text: 'Role name', placeholder: 'Role name') %>
  <%= f.submit 'Create', class: 'btn btn-primary' %>
<% end %>
```

上述两段代码生成的 form 如下

```html
<form action="/roles" accept-charset="UTF-8" data-remote="true" method="post"><input type="hidden" name="authenticity_token" value="geBn9JDocpOXYJMiOo+Yprd3NZIzcZOlPId0hYcNbHwgpIPOUugZpPfiu+mNzxa3UWDnVAt2K5zy6rhj1Ab3MQ==" />
  <div class="form-group">
    <label class="control-label" for="role_name">Role name</label>
    <input class="form-control " placeholder="Role name" type="text" name="role[name]" id="role_name" />
    <div class="invalid-feedback"></div>
  </div>
  <input type="submit" name="commit" value="Create" class="btn btn-primary" data-disable-with="Create" />
</form>
```

```
form = [form_group_0, form_group_1...] + input_submit
form_group = label + input + div_error_message
```

一个表单由一个或多个 form_group 组成。而一个 form_group 是由一个可选的 label + 输入框 input + 包含 error message 的 div 组成。我们将 form_group 封装起来可以少写很多重复的代码，并且能够保持 form 的一致性。
