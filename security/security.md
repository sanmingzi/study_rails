# 安全问题 (Security)

## SQL 注入

```SQL
INSERT INTO students (name) VALUES (@name);

-- normal SQL
@name = 'ming'
INSERT INTO students (name) VALUES ('ming');

-- attack
@name = "'ming'); DROP TABLE students; --"
INSERT INTO students (name) VALUES ('ming'); DROP TABLE students; --');
```

## HTML 注入

HTML 注入与 SQL 注入有点类似，如果你不检查用户输入的话，那么输入中就可能存在一些坏东西。比如其中可能会夹杂一些 js ，做一些奇怪的事情。

## CSRF

Cross-Site Request Forgery ，跨站伪造请求。

1. 浏览器访问网站 A ，并且进行登录，此时浏览器中的 cookie 会保存登录网站 A 的相关信息
2. 接着访问了一个有问题的网站 B ，B 会返回 HTML 给浏览器，但是会夹带私货。比如会有 \<img\> 之类浏览器自动载入的标签，而且其中内嵌了用来攻击网站 A 的 URL 。这就是典型的 CSRF 。

下面这份文档展示了 rails 是如何防止 CSRF 攻击的。

[CSRF](./rails_csrf.md)
