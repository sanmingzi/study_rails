# ActiveRecord Retrieve

- [find vs find_by vs where](https://stackoverflow.com/questions/11161663/find-vs-find-by-vs-where)

## find

- [find api](https://api.rubyonrails.org/v6.1.3.1/classes/ActiveRecord/FinderMethods.html#method-i-find)

```ruby
Order.find(1)
Order.find([1, 2])
```

只要有一个 id 不存在，find 方法将会抛出 RecordNotFound 异常。

## where

```ruby
Order.where("name = ? AND email = ?", 'test', 'test@test.com')
Order.where("name like ?", name + "%")

ActiveRecord::Relation.instance_methods.grep /(each|to_a)/
# => [:to_ary, :to_a, :find_each, :each, :each_with_index, :reverse_each, :each_entry, :each_slice, :each_cons, :each_with_object]
```

where 方法返回 ActiveRecord::Relation 的对象，该对象类似数组，有 to_a / each 方法，其中的每一个元素就是一个 ActiveRecord::Base 的对象。即便没有找到任何元素该方法也不会抛出异常，只是返回一个空的 ActiveRecord::Relation 对象。

## find_by

```ruby
Post.find_by name: 'Spartacus', rating: 4
Post.find_by "published_at < ?", 2.weeks.ago
```

```ruby
# File activerecord/lib/active_record/relation/finder_methods.rb, line 80
# https://github.com/rails/rails/blob/5aaaa1630ae9a71b3c3ecc4dc46074d678c08d67/activerecord/lib/active_record/relation/finder_methods.rb#L80

def find_by(arg, *args)
  where(arg, *args).take
end
```

通过源码可以看到，find_by 其实是调用了 where 方法，并且是取结果集中的第 1 个 record 。如果没有找到也不会抛出异常，只是返回值为 nil 。
