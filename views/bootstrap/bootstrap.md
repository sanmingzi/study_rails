# Bootstrap

- [ruby-china: Rails 6 中使用 jQuery 和 Bootstrap](https://ruby-china.org/topics/39543)

## 安装 Yarn

```
在 rails6 中，使用了新的方法了管理 JavaScript 包，那就是 Yarn，所以我们需要先安装 yarn，然后使用其来引入 bootstrap。
```

```Dockerfile
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt update && apt install -y yarn && \
```

## 添加 bootstrap

```bash
yarn add jquery
yarn add bootstrap
yarn add popper.js # 此为 bootstrap 的依赖包
```

## 引入 bootstrap

- application.css

```css
 *= require bootstrap/dist/css/bootstrap
 *= require_tree .
 *= require_self
```

- application.js

```js
require("bootstrap");
```
