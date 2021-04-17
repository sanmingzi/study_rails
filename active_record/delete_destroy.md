# Active Record Delete vs Destroy

```ruby
# delete & delete_all
Order.delete(1)
Order.delete([1, 2, 3])

Post.delete_all("person_id = 5 AND (category = 'Something' OR category = 'Else')")
Post.delete_all(["person_id = ? AND (category = ? OR category = ?)", 5, 'Something', 'Else'])

Post.where(:person_id => 5).where(:category => ['Something', 'Else']).delete_all
```

```ruby
# destroy & destroy_all
order = Order.find_by(name: 'test')
order.destroy

Order.destroy(1)
Order.destroy([1, 2, 3])

Post.destroy_all(["person_id = ? AND (category = ? OR category = ?)", 5, 'Something', 'Else'])

Post.where(:person_id => 5).where(:category => ['Something', 'Else']).destroy_all
```

delete 不会实例化将要删除的对象，只是单纯的执行 SQL ，所以速度会更快，但问题是不会去执行对应的 callback，这可能会导致数据库和 model 中定义的业务规则不一致。该方法返回被删除的数据的条数。

destroy 会实例化将要删除的对象，所以会触发 callback ，能够保证数据库和 model 中的规则一致，速度上会比 delete 要慢。

```ruby
# active_record/base.rb
def destroy
  unless new_record?
    connection.delete(
      "DELETE FROM #{self.class.quoted_table_name} " +
      "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quoted_id}",
      "#{self.class.name} Destroy"
    )
  end

  @destroyed = true
  freeze
end
```

```ruby
# ActiveRecord::Relation
def destroy(id)
  if id.is_a?(Array)
    id.map { |one_id| destroy(one_id) }
  else
    find(id).destroy
  end
end

def destroy_all(conditions = nil)
  if conditions
    where(conditions).destroy_all
  else
    to_a.each {|object| object.destroy }.tap { reset }
  end
end
```

通过查看源码，我们发现 destroy 是通过 find 方法去实例化对象，如果 id 不存在，destroy 方法会抛出异常。而 destroy_all 方法是通过 where 去查找对象，所以即使没找到需要删除的记录，该方法也不会抛出异常。还有一个地方不同，destroy 返回对象本身，destroy_all 返回 ActiveRecord::Relation 的对象。

```ruby
ActiveRecord::Base.methods.grep /^(delete|destroy)/
# => [:delete, :destroy, :delete_by, :delete_all, :destroy_by, :destroy_all]

ActiveRecord::Base.instance_methods.grep /^(delete|destroy)/
# => [:destroy, :destroyed_by_association=, :destroyed_by_association, :delete, :destroyed?, :destroy!]

ActiveRecord::Relation.methods.grep /^(delete|destroy)/
# => []

ActiveRecord::Relation.instance_methods.grep /^(delete|destroy)/
# => [:destroy_all, :destroy_by, :delete_by, :delete_all]
```
