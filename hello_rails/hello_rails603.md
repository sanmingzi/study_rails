# 使用rails603创建新项目

## 基于mysql创建项目

```
rails new hello_rails -d mysql --skip-bundle --skip-webpack-install
```

## 修改Gemfile

- 修改gem source
- 不使用webpack

Gemfile

```
# source 'https://rubygems.org'
source 'https://gems.ruby-china.com/'

#···
#···

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 4.0'
```

## 修改database.yml

```
development:
  # <<: *default
  # database: hello_world_development
  url: mysql2://root:root@127.0.0.1/hello_rails_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  # <<: *default
  # database: hello_world_test
  url: mysql2://root:root@127.0.0.1/hello_rails_test
```

修改这个文件，是为了避免rails通过 ```mysqld.sock``` 去连接mysql数据库，避免报错。

## 执行命令

```
bundle install --path vendor/bundle
ENV=development bundle exec rails db:create
ENV=development bundle exec rails db:migrate
ENV=development bundle exec rails s -b 0.0.0.0 -p 3000
```

访问 [localhost:3000](localhost:3000) 应该就能看到index页面了。
