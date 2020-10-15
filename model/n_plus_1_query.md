# N + 1 问题

## 什么是 N + 1 问题

```SQL
N + 1 问题是数据库访问中最常见的一个性能问题。举个例子：

在一个权限数据库中有三张表，roles / permissions / role_permissions。想要得到所有的 role 以及其对应的 permission，一种写法是：

SELECT * FROM roles;

对于每一个 role，

SELECT * FROM permissons p
JOIN role_permissions rp ON p.id = rp.permission_id
WHERE rp.role_id = role_id; 

在上述过程中，我们实际对数据库进行了 N + 1 次查询，第 1 次是查询所有的 role，对于 N 个 role 分别对其对应的 permission 进行 N 次查询，所以一共查询了 N + 1 次。
```

## N + 1 问题的一般解决方法

```SQL
数据如下：


CREATE TABLE roles (id INTEGER(32), name VARCHAR(32));
CREATE TABLE permissions(id INTEGER(32), name VARCHAR(32));
CREATE TABLE role_permissions(role_id INTEGER(32), permission_id INTEGER(32));

INSERT INTO roles (id, name) VALUES (1, "r_1"), (2, "r_2");
INSERT INTO permissions (id, name) VALUES (1, "p_1"), (2, "p_2"), (3, "p_3"), (4, "p_4");
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 1), (1, 2), (1, 3), (2, 2), (2, 3), (2, 4);

我们可以使用 JOIN 来一次性查询所需的数据：

SELECT r.id role_id, r.name role_name, p.id permission_id, p.name permission_name 
FROM roles r
JOIN role_permissions rp ON rp.role_id = r.id
JOIN permissions p ON rp.permission_id = p.id
ORDER BY role_id, permission_id;

SELECT r.id role_id, r.name role_name, p.id permission_id, p.name permission_name
FROM roles r, role_permissions rp, permissions p
WHERE r.id = rp.role_id
AND rp.permission_id = p.id
ORDER BY role_id, permission_id;

+---------+-----------+---------------+-----------------+
| role_id | role_name | permission_id | permission_name |
+---------+-----------+---------------+-----------------+
|       1 | r_1       |             1 | p_1             |
|       1 | r_1       |             2 | p_2             |
|       1 | r_1       |             3 | p_3             |
|       2 | r_2       |             2 | p_2             |
|       2 | r_2       |             3 | p_3             |
|       2 | r_2       |             4 | p_4             |
+---------+-----------+---------------+-----------------+
```

## ActiveRecord N + 1 问题

```ruby
class Role < ActiveRecord::Base
  has_many :role_permissions
  has_many :permissions, :through => :role_permissions
end

# The next code will cause the N+1 query.

Role.all.each do |role|s
  puts role.permissions.inspect
end

# We can fix it only use the includes, the next code only access db one time.
Role.includes(:permissions).each do |role|
  puts role.permissions.inspect
end
```

## Again, N + 1 problem

```ruby
class Role < ActiveRecord::Base
  has_many :role_permissions
  has_many :permissions, :through => :role_permissions
end

def print_role_permissions(role)
  role.role_permissions.each do |role_permission|
    puts role_permission.permission.inspect
  end
end

# The next code use 'includes', but it also has N+1 query.
role = Role.includes(:role_permissions, :permissions).first
print_role_permissions(role)

# When there are relationship between the included objects, we should use `=>`. The next code can void N + 1 query problem.
role = Role.includes(:role_permissions => :permissions).first
print_role_permissions(role)
```
