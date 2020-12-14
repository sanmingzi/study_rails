# form_with vs form_for

- [form_with — Building HTML forms in Rails 5.1](https://medium.com/@tinchorb/form-with-building-html-forms-in-rails-5-1-f30bd60ef52d#:~:text=The%20difference%20between%20form_for%20and,while%20the%20latter%20does%20not.&text=Clearly%2C%20both%20ways%20of%20building,url%20for%20building%20the%20form.)

```
Rails 5.1 中添加了 form_with 方法来帮助用户创建表单。
在这之前，我们使用 form_for / form_tag 来创建表单。
```

## form_for

```ruby
<%= form_for @post do |form| %>
  <%= form.text_field :author %>
  <%= form.submit "Create" %>
<% end %>

<form class="new_post" id="new_post" action="/posts" accept-charset="UTF-8" method="post">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="…">
  <input type="text" name="post[author]" id="post_author">
  <input type="submit" name="commit" value="Create" data-disable-with="Create">
</form>
```

## form_tag

```ruby
<%= form_tag "/posts" do %>
  <%= text_field_tag "post[author]" %>
  <%= submit_tag "Create" %>
<% end %>

<form action="/posts" accept-charset="UTF-8" method="post">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="…">
  <input type="text" name="post[author]" id="post_author">
  <input type="submit" name="commit" value="Create" data-disable-with="Create">
</form>
```

## form_with

```ruby
<%= form_with model: @post do |form| %>
  <%= form.text_field :author %>
  <%= form.submit "Create" %>
<% end %>

<form action="/posts" accept-charset="UTF-8" method="post" data-remote="true">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="…">
  <input type="text" name="post[author]">
  <input type="submit" name="commit" value="Create" data-disable-with="Create">
</form>

<%= form_with url: "/posts" do |form| %>
  <%= form.text_field :author %>
  <%= form.submit "Create" %>
<% end %>

<form action="posts" accept-charset="UTF-8" method="post" data-remote="true">
  <input name="utf8" type="hidden" value="✓">
  <input type="hidden" name="authenticity_token" value="…">
  <input type="text" name="author">
  <input type="submit" name="commit" value="Create" data-disable-with="Create">
</form>
```

## 区别

- data-remote

```
从生成的 HTML 可以看出 form_with 默认 data-remote: true。
如果我们想改变这个值，可以设置 local: true。
```

- scope prefix

```ruby
<%= form_with url: “/posts”, scope: “post” do |form| %>
  <%= form.text_field :author %>
  <%= form.submit “Create” %>
<% end %>

<form action=”posts” accept-charset=”UTF-8" data-remote=”true” method=”post”>
  <input name=”utf8" type=”hidden” value=”✓”>
  <input type=”hidden” name=”authenticity_token” value=”…”>
  <input type=”text” name=”post[author]”>
  <input type=”submit” name=”commit” value=”Create” data-disable-with=”Create”>
</form>
```

```
scope 选项可以作为每个 input field 的前缀。
如果我们使用的是 form_tag 的话，需要在每一个 input 前面手动添加前缀名。
```

- input fields 可以不和 model attributes 对应

```ruby
<%= form_with model: @post do |form| %>
  <%= form.text_field :author %>
  <%= form.check_box :notify_readers %>
  <%= form.submit “Create” %>
<% end %>

<form action=”/posts” accept-charset=”UTF-8" data-remote=”true” method=”post”>
  <input name=”utf8" type=”hidden” value=”✓”>
  <input type=”hidden” name=”authenticity_token” value=”…”>
  <input type=”text” name=”post[author]”>
  <input name=”post[notify_readers]” type=”hidden” value=”0"><input type=”checkbox” value=”1" name=”post[notify_readers]”>
  <input type=”submit” name=”commit” value=”Create” data-disable-with=”Create”>
</form>
```

```
我们在上述代码中添加了一个 check_box。很显然，这个 check_box 并不是 post 的属性。
这个 check_box 的意思是，当作者在创建了一个 post 的时候，是否需要通知读者。
input fields 和 attributes 不完全匹配的好处给了开发者更多的空间。
```

- 不会自动额外添加 ids / classes

```
form_for 和 form_tag 会为 input 添加额外的 id。form_for 甚至会为表单自动添加一些 class。
form_with 不会这样做，开发者需要自己定义组件的 id 和 class。
```

- html 选项

```ruby
<%= form_for @post, html: { id: "custom-id", class: "custom-class" } do |form| %>

<%= form_with model: @post, id: "custom-id", class: "custom-class" do |form| %>
```

```
form_for 和 form_tag 通过 html 选项来添加组件的属性，比如 id / class 等。
form_with 可以直接将 id / class 添加在一级选项中。
```
