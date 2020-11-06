# form_with

form_with 是 rails 中用来创建表单的 helper 方法。

- demo

```ruby
<%= form_with(path, method: :get, local: true) do |f| %>
  <%= f.text_field :value0 %>
  <%= f.submit 'Submit' %>
<% end %>
```

- method

```
在表单提交中，默认使用的是 post 方法，我们可以将其设置为 get。
```

- local or remote

```
默认 remote: true，使用 xhr(XMLHttpRequest) 提交表单。
在有些时候这种方式达不到我们想要的效果。
比如，我们创建一个检索表单，希望表单提交后能够刷新页面，如果使用 xhr 提交的话是做不到的。
此时，我们就可以设置 local: true。这样在提交表单后能够刷新页面。

当然我们可以通过 ajax 来实现检索后局部刷新页面，这应该是更好的方法。但相对来说会复杂一点。
```
