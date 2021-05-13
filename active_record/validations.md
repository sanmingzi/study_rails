# Rails Active Record Validations

- [rails guide active_record validations](https://guides.rubyonrails.org/active_record_validations.html)

## Trigger Validations

```ruby
create
create!
save
save!
update
update!
```

## Skipping Validations

```ruby
update_all
update_attribute
update_column
update_columns
update_counters
```

```ruby
save(validate: false)
```

## valid? and invalid?

```ruby
class Role < ApplicationRecord
  validates :name, presence: true
end

role = Role.new
role.valid?
# => false
role.errors.messages
# => {:name=>["can't be blank"]}
```

```
我们可以通过 valid? / invalid? 方法来手动触发 ActiveRecord 的 validation
```

## errors

```ruby
class Role < ApplicationRecord
  validates :name, presence: true
end

role = Role.new

role.errors
# => #<ActiveModel::Errors:0x000056444a59ad78 @base=#<Role id: nil, name: nil, status: true, created_at: nil, updated_at: nil>, @messages={:name=>["can't be blank"]}, @details={:name=>[{:error=>:blank}]}>

role.errors[:name]
role.errors.messages[:name]
# => ["can't be blank"]

role.errors.details[:name]
# [{:error=>:blank}]
```

## Validation Helpers

- acceptance

当表单提交时，用于校验 checkbox 是否被选中。最常见的场景就是用户同意服务条款；该字段一般来讲是 virtual attribute，数据库中一般不存储；只有当被校验的字段不为 nil 的时候，该校验才会生效；可以自定义 error message，以及该字段的 accept value；

```ruby
class Role < ApplicationRecord
  validates :terms_of_service, acceptance: {accept: ['TRUE', 'accepted'], message: 'must be abided'}
end

role = Role.new
role.valid?
# => true

role.terms_of_service = false
role.valid?
# => false

role.terms_of_service = 'TRUE'
role.valid?
# => true
```

- confirmation

这个校验主要用来确认输入是否一致。最常见的场景就是密码的重复确认；下面的代码以 email confirm 为例，其中 email 是 model 真实的 attribute，email_confirmation 是生成的一个 virtual attribute；

```ruby
class Role < ApplicationRecord
  attr_accessor :email

  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end

role = Role.new(email: 'test', email_confirmation: 'test0')
role.valid?
# => false

role.email_confirmation = 'test'
role.valid?
# => true
```

- inclusion / exclusion

如果 inclusion 中没有 nil 和 ''，但是 value = nil / ''，校验失败；如果exclusion 中没有 nil 和 ''，但是 value = nil / ''，校验成功；

```ruby
class Role < ApplicationRecord
  attr_accessor :domain, :subdomain

  validates :domain, inclusion: {in: %w(www us ca jp), message: "%{value} is reserved."}
  validates :subdomain, exclusion: {in: %w(www us ca jp), message: "%{value} is reserved."}
end

role = Role.new
role.domain = 'test'
role.valid? # false
role.domain = 'www'
role.valid? # true

role = Role.new(domain: 'www')
role.subdomain = 'www'
role.valid? # false
role.subdomain = 'test'
role.valid? # true
```

- format

```ruby
class Role < ApplicationRecord
  attr_accessor :legacy_code

  validates :legacy_code, format: {with: /\A[a-zA-Z]+\z/, message: "only allows letters"}
end

role = Role.new
role.valid? # false
role.legacy_code = 'abc'
role.valid? # true
```

- length

```ruby
class Role < ApplicationRecord
  attr_accessor :num0, :num1, :num2, :num3

  validates :num0, length: {minimum: 2}
  validates :num1, length: {maximum: 10}
  validates :num2, length: {in: 2..10}
  validates :num3, length: {is: 6}
end

[[:num0, '0'], [:num1, '01234567890'], [:num2, '0'], [:num3, '0123456']].each do |attr, value|
  role = Role.new
  role.send("#{attr}=", value)
  puts role.valid?
  puts role.errors[attr]
end
# is too short (minimum is 2 characters)
# is too long (maximum is 10 characters)
# is too short (minimum is 2 characters)
# is the wrong length (should be 6 characters)
```

- numericality

```
By default, it match integer or float, not match nil. You can use options to change it.
```

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: {only_integer: true}
end
```

```ruby
only_integer: false
allow_nil: false
greater_than:
greater_than_or_equal_to:
equal_to:
less_than:
less_than_or_equal_to:
other_than:
odd:
even:
```

- presence / absence

presence 用来校验某个属性不为 nil / false, 且不为空，其使用的是 blank? 方法；absence 和 presence 恰好相反，其使用的是 present? 方法；

```ruby
class Role < ApplicationRecord
  attr_accessor :name, :email

  validates :name, presence: true
  validates :email, absence: true
end

role = Role.new
[nil, '', false].each do |value|
  role.name = value
  role.valid?
  role.errors[:name]
end
# false
# can't be blank

role = Role.new
[nil, '', false].each do |value|
  role.email = value
  role.valid?
end
# true
```

- uniqueness

```ruby
class Role < ApplicationRecord
  attr_accessor :name, :year, :month

  validates :name, uniqueness: {scope: [:year, :month], case_sensitive: false, message: 'should happen once per year per month'}
end
```

scope 后面可以接多个 attribute，有点类似联合唯一索引；case_sensitive: false 表示不区分大小写；

## Common Validation Options

- allow_nil
- allow_blank
- message

## Conditional Validation

- if: and unless:

```ruby
class Role < ApplicationRecord
  attr_accessor :name, :is_admin

  validates :name, presence: true, if: :is_admin?

  def is_admin?
    is_admin == true
  end
end

role = Role.new(is_admin: false)
puts role.valid? # true

role = Role.new(is_admin: true)
puts role.valid? # false
role.name = 'admin'
puts role.valid? # true
```

- Proc with if: and unless:

```ruby
class Role < ApplicationRecord
  attr_accessor :name, :is_admin

  validates :name, presence: true, if: -> {is_admin == true}
end
```

- Grouping Conditional validations

```ruby
class Role < ApplicationRecord
  attr_accessor :name, :password, :is_admin

  with_options if: -> {is_admin == true} do |admin|
    admin.validates :name, presence: true
    admin.validates :password, presence: true
  end
end

role = Role.new(is_admin: false)
role.valid? # true

role = Role.new(is_admin: true)
role.valid? # false
```

- Combining Validation Conditions

```ruby
class Role < ApplicationRecord
  attr_accessor :password, :is_admin

  validates :password, confirmation: true
  validates :password_confirmation, presence: true, if: [-> {is_admin == true}, -> {password.present?}, :confirm?]

  def confirm?
    true
  end
end

role = Role.new(is_admin: true)
role.valid? # true

role.password = 'pwd'
role.valid? # false
role.errors[:password_confirmation] # ["can't be blank"]

role.password_confirmation = 'p'
role.valid? # false
role.errors[:password_confirmation] # ["doesn't match Password"]

role.password_confirmation = 'pwd'
role.valid? # true
```

## Custom Validations

- Custom Validator EachValidator

```ruby
class StringValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if(value == nil || !value.is_a?(String))
      record.errors[attribute] << (options[:message] || 'is not a string')
    else
      if options[:minimum] && value.length < options[:minimum]
        record.errors[attribute] << (options[:message] || "too short (minimum length is #{options[:minimum]})")
      end
      if options[:maximum] && value.length > options[:maximum]
        record.errors[attribute] << (options[:message] || "too long (maximum length is #{options[:maximum]})")
      end
    end
  end
end

class Role < ApplicationRecord
  attr_accessor :name

  validates :name, string: {minimum: 2, maximum: 6}, allow_nil: true
end

role = Role.new
role.valid? # true
role.name = '1'
role.valid? # false
role.errors[:name] # => ["too short (minimum length is 2)"]
role.name = '01'
role.valid? # true
```

- Custom Methods

```ruby
class Role < ApplicationRecord
  attr_accessor :is_admin

  validate :common_name_can_not_be_admin

  def common_name_can_not_be_admin
    if is_admin == false && name == 'admin'
      errors.add(:name, 'common name can not be admin')
    end
  end
end

role = Role.new(is_admin: true, name: 'admin')
role.valid? # true
role.is_admin = false
role.valid? # false
```

## Displaying Validation Errors in Views

```html
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>

    <ul>
    <% @article.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```