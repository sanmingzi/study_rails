# preload includes eager_load joins

- https://blog.bigbinary.com/2013/07/01/preload-vs-eager-load-vs-joins-vs-includes.html


## preload

- 基本用法

```ruby
PackageType.preload(:packages)

SELECT `package_types`.* FROM `package_types`
SELECT `packages`.* FROM `packages` WHERE `packages`.`package_type_id` IN (1, 2, 3, 4, 5)

最基本用法，preload会使用两个SQL查询，可以避免 n + 1 问题
```

- 条件查询

```ruby
PackageType.preload(:packages).where("name = 'jackpot'")

SELECT `package_types`.* FROM `package_types` WHERE (name = 'jackpot')
SELECT `packages`.* FROM `packages` WHERE `packages`.`package_type_id` IN (5)

还是会使用两个SQL查询，在preload后面添加where条件查询，该条件只会作用在第一个SQL对象上
```

- 错误使用

```ruby
PackageType.preload(:packages).where("packages.name = 'jackpot'")

SELECT `package_types`.* FROM `package_types` WHERE (packages.name = 'jackpot')
ERROR:  Unknown column 'packages.name'

因为preload后面所加的where条件只会用在第一个SQL语句上，所以如果强行在where条件中加上其他对象名的限制，则会出错
```

## includes

- 基本用法

```ruby
PackageType.includes(:packages)

SELECT `package_types`.* FROM `package_types`
SELECT `packages`.* FROM `packages` WHERE `packages`.`package_type_id` IN (1, 2, 3, 4, 5)
```

- 条件查询

```ruby
PackageType.includes(:packages).where("name = 'jackpot'")

SELECT `package_types`.* FROM `package_types` WHERE (name = 'jackpot')
SELECT `packages`.* FROM `packages` WHERE `packages`.`package_type_id` IN (5)
```

- 子条件查询

```ruby
PackageType.includes(:packages).where("packages.name = 'jackpot'")

SELECT `package_types`.*, `packages`.* FROM `package_types` LEFT OUTER JOIN `packages` ON `packages`.`package_type_id` = `package_types`.`id` WHERE (packages.name = 'jackpot')

在preload中用这种写法是语法错误，因为preload无法使用子条件查询
但是如果是includes的话，则只会生成一条SQL语句
```

## eager_load

- 基本用法

eager_load using one single query to load all association

```ruby
PackageType.eager_load(:packages)
=>
SELECT `package_types`.*, `packages`.* FROM `package_types` LEFT OUTER JOIN `packages` ON `packages`.`package_type_id` = `package_types`.`id`
```

## joins

```ruby
PackageType.joins(:packages)

SELECT `package_types`.* FROM `package_types` INNER JOIN `packages` ON `packages`.`package_type_id` = `package_types`.`id`

问题1：
上述 SQL 只查询了 package_types 并未查询 packages，容易造成 n + 1 问题

问题2：
duplication的问题。joins查询返回结果的个数取决于两个对象之间foreign key的个数，也就是子类的数目，所以很容易出现duplication。
PackageType.joins(:packages).select('distinct package_types.*')
这种方法可以解决duplication的问题。
```

## 总结

```ruby
preload 会根据查询对象的数目生成多条 SQL。但是 preload 的条件查询只能应用在第一级对象上

eager_load 会使用 LEFT OUT JOIN 生成一条 SQL 语句来查询所有的结果

如果条件查询应用在第一级对象上，includes 的表现同 preload 一致；如果条件查询不是针对第一级对象的话，includes 的表现同 eager_load 一致

joins 使用 INNER JOIN 来查询第一级对象的数据，容易造成 n + 1 查询问题。如果父对象和子对象是一对多的关系还会出现重复的数据。

Role.create(id: 1, name: 'role1')
Role.create(id: 2, name: 'role2')
Permission.create(id: 1, name: 'permission1', action: '', resource: '')
Permission.create(id: 2, name: 'permission2', action: '', resource: '')
RolePermission.create(role_id: 1, permission_id: 1)
RolePermission.create(role_id: 1, permission_id: 2)
RolePermission.create(role_id: 2, permission_id: 1)
RolePermission.create(role_id: 2, permission_id: 2)
Role.joins(:permissions)

SELECT `roles`.* FROM `roles` INNER JOIN `role_permissions` ON `role_permissions`.`role_id` = `roles`.`id` INNER JOIN `permissions` ON `permissions`.`id` = `role_permissions`.`permission_id` LIMIT 11

=> #<ActiveRecord::Relation [#<Role id: 1, name: "role1", status: true, created_at: "2020-09-30 10:13:43", updated_at: "2020-09-30 10:13:43">, #<Role id: 1, name: "role1", status: true, created_at: "2020-09-30 10:13:43", updated_at: "2020-09-30 10:13:43">, #<Role id: 2, name: "role2", status: true, created_at: "2020-09-30 10:13:58", updated_at: "2020-09-30 10:13:58">, #<Role id: 2, name: "role2", status: true, created_at: "2020-09-30 10:13:58", updated_at: "2020-09-30 10:13:58">]>
```
