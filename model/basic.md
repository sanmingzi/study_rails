# 基础

- [active_record_basics](https://guides.rubyonrails.org/active_record_basics.html)

## 命名约定

```
Model Clas: 单数，首字母大写，驼峰命名法
Database Table: 复数，小写，用下划线连接
```

Model / Class | Table / Schema
--- | ---
Article | articles
Book | books

## 覆盖命名约定

- 指定表名

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end

class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
end
```

- 指定主键

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

## Create

```ruby
role = Role.create(name: 'admin')
role = Role.create do |r|
  r.name = 'admin'
end

role = Role.new(name: 'admin')
role.save
role = Role.new do |u|
  u.name = 'admin'
end
role.save
```

## Read

```ruby
roles = Role.all
role = Role.find(1)
role = Role.find_by(name: 'admin')
role = Role.where(name: 'admin')
```

[find vs find_by vs where](rails_find_find_by_where.md)
                             
## Update

```ruby
role = Role.find_by(name: 'admin')
role.name = 'test'
role.save

role = Role.find_by(name: 'admin')
role.update(name: 'test')
```

## Delete

```ruby
# delete the first record which name is test
role = Role.find_by(name: 'test')
role.destroy

# delete all records which name is test
Role.destroy_by(name: 'test')

# delete all records
Role.destroy_all
```

```
model 的类方法 destroy_by / destroy_all 会先 SELECT 所有的满足条件的 record，
然后会删除这些 record one by one，所以这两个批量方法会比较慢。
感觉可以尝试使用 truncate。
另外，最好不要删除数据库中的数据，我们可以通过 status 来标记 record 是否已经删除。
```

## Validations

```ruby
class Role < ApplicationRecord
  validates :name, presence: true
end
```

[validations.md](validations.md)

## Callbacks

```
TODO
```

## Migrations

[migrations.md](migrations.md)
