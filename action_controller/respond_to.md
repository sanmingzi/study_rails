# Action Controller respond_to

```ruby
respond_to do |format|
  format.html
  format.js
  format.json
end
```

这是我们经常在 controller 中这样使用 respond_to ，将一个 block 传递给 respond_to 。

```ruby
# how can I find where is the respond_to
ancestors = []
ApplicationController.ancestors.each do |c|
  ancestors.push(c) if [] != c.instance_methods(false).grep(/respond_to$/)
end
puts ancestors.inspect
# [ActionController::MimeResponds]
```

在 ApplicationController 中并没有定义 respond_to 方法。于是我通过上述代码找到了 respond_to 定义在 ActionController::MimeResponds 。

```ruby
# File actionpack/lib/action_controller/metal/mime_responds.rb, line 201
# https://github.com/rails/rails/blob/85c6823b77b60f2a3a6a25d7a1013032e8c580ef/actionpack/lib/action_controller/metal/mime_responds.rb#L201

def respond_to(*mimes)
  raise ArgumentError, "respond_to takes either types or a block, never both" if mimes.any? && block_given?

  collector = Collector.new(mimes, request.variant)
  yield collector if block_given?

  if format = collector.negotiate_format(request)
    if media_type && media_type != format
      raise ActionController::RespondToMismatchError
    end
    _process_format(format)
    _set_rendered_content_type(format) unless collector.any_response?
    response = collector.response
    response.call if response
  else
    raise ActionController::UnknownFormat
  end
end
```

在 respond_to 的内部会通过 yield 关键字调用 block ，并将 collector 作为参数传递给 block 。也就是说我们在 block 中使用的 format 其实是一个 collector 。

我继续查阅文档 [Collector](https://github.com/rails/rails/blob/85c6823b77b60f2a3a6a25d7a1013032e8c580ef/actionpack/lib/action_controller/metal/mime_responds.rb#L242) ，发现这类中根本就没有定义 html / js / json 等方法。于是一切都回到了熟悉的 method_missing 。而且这个 method_missing 方法还定义在其加载的模块 AbstractController::Collector 里面。

```ruby
# https://github.com/rails/rails/blob/3b40a5d83db90534b3cb61f4dc25547f501e4775/actionpack/lib/abstract_controller/collector.rb
require "action_dispatch/http/mime_type"

module AbstractController
  module Collector
    def self.generate_method_for_mime(mime)
      sym = mime.is_a?(Symbol) ? mime : mime.to_sym
      const = sym.upcase
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{sym}(*args, &block)                # def html(*args, &block)
          custom(Mime::#{const}, *args, &block)  #   custom(Mime::HTML, *args, &block)
        end                                      # end
      RUBY
    end

    Mime::SET.each do |mime|
      generate_method_for_mime(mime)
    end

    Mime::Type.register_callback do |mime|
      generate_method_for_mime(mime) unless self.instance_methods.include?(mime.to_sym)
    end

  protected

    def method_missing(symbol, &block)
      const_name = symbol.upcase

      unless Mime.const_defined?(const_name)
        raise NoMethodError, "To respond to a custom format, register it as a MIME type first: " \
          "http://guides.rubyonrails.org/action_controller_overview.html#restful-downloads. " \
          "If you meant to respond to a variant like :tablet or :phone, not a custom format, " \
          "be sure to nest your variant response within a format response: " \
          "format.html { |html| html.tablet { ... } }"
      end

      mime_constant = Mime.const_get(const_name)

      if Mime::SET.include?(mime_constant)
        AbstractController::Collector.generate_method_for_mime(mime_constant)
        send(symbol, &block)
      else
        super
      end
    end
  end
end
```
