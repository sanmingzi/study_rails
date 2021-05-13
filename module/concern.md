# DRY Concern

- [ActiveSupport::Concern](https://api.rubyonrails.org/v6.0.3.3/classes/ActiveSupport/Concern.html#method-i-included)
- [ruby-china](https://ruby-china.org/topics/19812)

## demo

```ruby
require 'active_support/concern'

module Activeable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
  end

  def is_active?
    status == 'Enable'
  end
end

class Role
  include Activeable

  attr_accessor :status

  def initialize(status: 'Enable')
    @status = status
  end
end

class Permission
  include Activeable

  attr_accessor :status

  def initialize(status: 'Disable')
    @status = status
  end
end

puts Role.new.is_active?
puts Permission.new.is_active?
```

## concern 用来解决复杂的依赖问题

- 常规写法

```ruby
module Foo
  def self.included(base)
    puts base.inspect

    base.class_eval do
      def self.method_injected_by_foo
      end
    end
  end
end

module Bar
  def self.included(base)
    base.method_injected_by_foo
  end
end

class Host
  include Foo # We need to include this dependency for Bar
  include Bar # Bar is the module that Host really needs
end

```

```m
上述代码中有多重依赖关系，Host -> Bar -> Foo
问题在于，当我们在 Host 中引入 Bar 的时候，必须先引入 Bar 所依赖的模块 Foo，但其实 Host 并不关心 Bar 所依赖的东西。我们可以尝试在 Bar 中直接引入其 Foo。
```

- 尝试

```ruby
module Foo
  def self.included(base)
    puts base.inspect

    base.class_eval do
      def self.method_injected_by_foo
      end
    end
  end
end

module Bar
  include Foo

  def self.included(base)
    base.method_injected_by_foo
  end
end

class Host
  include Bar # Bar is the module that Host really needs
end

# undefined method `method_injected_by_foo' for Host:Class (NoMethodError)
```

但是，这种写法是错误的。我们在 Bar 模块中引入依赖 Foo，此时会触发 Foo 的回调函数 included，而此时的 base = Bar，接下来的 base.class_eval 会在 Bar 内部注入了一个 class method，而 module 内部的 class method 不会 mix 到父类中去，所以最终 Host 内没有 method_injected_by_foo 函数。

- 使用 concern 解决依赖问题

```ruby

require 'active_support/concern'

module Foo
  extend ActiveSupport::Concern

  included do
    puts self.inspect

    def self.method_injected_by_foo
    end
  end
end

module Bar
  extend ActiveSupport::Concern
  include Foo

  included do
    puts self.inspect

    self.method_injected_by_foo
  end
end

class Host
  include Bar # It works, now Bar takes care of its dependencies
end

# Host
# Host
```
