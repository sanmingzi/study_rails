# 使用mysql作为rails的数据库

rails默认使用sqlite3作为数据库。在日常的开发中，我使用较多的是mysql数据库，所以有必要将sqlite3换成mysql。

## 使用mysql创建项目

```
rails new app -d mysql --skip-bundle
```

该命令可指定使用mysql作为数据，同时会生成相应的database.yml文件。

## 修改database.yml

原始内容

```
development:
  <<: *default
  database: hello_world_development

test:
  <<: *default
  database: hello_world_test
```

修改后

```
development:
  url: mysql2://root:root@127.0.0.1/hello_world_development

test:
  url: mysql2://root:root@127.0.0.1/hello_world_test
```

这个地方的设置值得注意。如果我们设置的host是localhost或者是其他域名的话，rails会通过 ```/var/run/mysqld/mysqld.sock``` 该sock向mysql server发起连接，但是这个文件本身是不存在的，所以在执行migrate的时候会报错。类似下面：

```
rails aborted!
Mysql2::Error::ConnectionError: Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)
```

如果是开发或者测试环境的话，完全可以将host设置为真实的ip地址。至于生产环境该如何配置还需要进一步的研究。

开发环境中，不仅要配置development，还要记得配置test哦，否则会报错。

## 总结

- 创建rails app的时候指定使用何种数据库比较有效
- 开发和测试环境可以将host设置为真实的ip地址，避免出现数据库连接错误
- 配置development环境的同时要配置test环境，否则会报错
- 生产环境的配置还需要进一步研究
