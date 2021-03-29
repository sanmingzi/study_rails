# Migrations

## Create Migration

- Standalone Migration

```ruby
bundle exec rails generate migration CreateRoles
```

- Model Generators

```
bundle exec rails generate model Role
```

## Writing Migration

```ruby
create_table :roles do |t|
  t.string :name, null: false
end

# This will create a table roles_permissions
# with two column role_id / permission_id
create_join_table :roles, :permissions, table_name: :roles_permissions do |t|
end

change_talbe :roles do |t|
  t.remove :name, :status # remove two column
  t.string :name # create column name
  t.rename :admin, :is_admin # rename column
  t.index :uuid # add index of uuid
end

change_column :roles :name, :text # change name to text
change_column_null :products, :name, false # change name NOT NULL
change_column_default :products, :approved, from: true, to: false # change default from true to false

# add foreign key author_id to articles
add_foreign_key :articles, :authors

remove_foreign_key :articles, :authors
remove_foreign_key :articles, column: :author_id
remove_foreign_key :articles, name: :fk_rails_author_id
```

- uniq index

```ruby
create_table :roles do |t|
  t.string :name, index: { unique: true }, null: false
end

add_index :table_name, :column_name, unique: true
add_index :table_name, [:column_name_a, :column_name_b], unique: true
```

- up / down

```ruby
class CreateRoles < ActiveRecord::Migration[5.0]
  def up
    create_table :roles do |t|
      t.string :name
    end
  end
 
  def down
    drop_table :roles
  end
end
```

## Running Migration

```ruby
# create the database
bundle exec rails db:setup

# drop the database and set it up again
bundle exec rails db:reset

bundle exec rails db:migrate
bundle exec rails db:migrate RAILS_ENV=test
bundle exec rails db:migrate VERSION=20200906120000

bundle exec rails db:rollback
bundle exec rails db:rollback STEP=3

bundle exec rails db:migrate:up VERSION=20200906120000
bundle exec rails db:migrate:down VERSION=20200906120000
```

## Seed Data

db/seeds.rb

```ruby
Role.create(name: 'admin', is_admin: true)
Role.create(name: 'test', is_admin: false)
```

```ruby
bundle exec rails db:seed RAILS_ENV=development
```

```
We can use seed, it is useful to init the database.
```
