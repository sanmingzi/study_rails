# Routing

- [Routing](https://guides.rubyonrails.org/routing.html)

## URLs & Path & Code

```ruby
GET /patients/17
get '/patients/:id', to: 'patients#show', as: 'patient'
<%= link_to 'Patient Record', patient_path(@patient) %>
```

```ruby
class PatientsController < ApplicationController
  def show
    @patient = Patient.find(params[:id])
  end
end
```

## Resource Routing

- resources

```ruby
resources :photos
```

HTTP Verb | Path | Path Helper | Controller#Action
- | - | - | -
GET       | /photos          | photos_path          | photos#index
GET       | /photos/new      | new_photo_path       | photos#new
POST      | /photos          |                      | photos#create
GET       | /photos/:id      | photo_path(:id)      | photos#show
GET       | /photos/:id/edit | edit_photo_path(:id) | photos#edit
PATCH/PUT | /photos/:id      |                      | photos#update
DELETE    | /photos/:id      |                      | photos#destroy

- resource

```ruby
resource :profile
```

HTTP Verb | Path | Path Helper | Controller#Action
- | - | - | -
GET       | /profile/new  | new_profile_path  | profiles#new
POST      | /profile      |                   | profiles#create
GET       | /profile      | profile_path      | profiles#show
GET       | /profile/edit | edit_profile_path | profiles#edit
PATCH/PUT | /profile      |                   | profiles#update
DELETE    | /profile      |                   | profiles#destroy

- namespaces

```ruby
namespace :api do
  resources :articles
end
```

```
GET	/admin/articles	    admin/articles#index	admin_articles_path
GET	/admin/articles/new	admin/articles#new	  new_admin_article_path
```

- member route

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```

```ruby
resources :photos do
  get 'preview', on: :member
end
```

```
GET /photos/:id/preview photos#preview preview_photo_path
```

- collection route

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

```ruby
resources :photos do
  get 'search', on: :collection
end
```

```
GET /photos/search photos#search search_photos_path
```

## Non-Resourceful Routes

```ruby
get 'photos(/:id)', to: 'photos#display' # the id is optional
get 'photos/:id/:user_id', to: 'photos#show'
get 'exit', to: 'sessions#destroy', as: :logout

get '/stories', to: redirect('/articles')
get '/stories/:name', to: redirect('/articles/%{name}')
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)

root to: 'pages#main'
root 'pages#main' # shortcut for the above
```

## Customizing Resourceful Routes

- 自定义 controller

```ruby
resources :photos, controller: 'images'
```

HTTP Verb | Path | Controller#Action | Route Helper
- | - | - | -
GET       | /photos          | images#index   | photos_path
GET       | /photos/new      | images#new     | new_photo_path
POST      | /photos          | images#create  | photos_path
GET       | /photos/:id      | images#show    | photo_path(:id)
GET       | /photos/:id/edit | images#edit    | edit_photo_path(:id)
PATCH/PUT | /photos/:id      | images#update  | photo_path(:id)
DELETE    | /photos/:id      | images#destroy | photo_path(:id)

```ruby
在上面的示例中，我们可以对 resources 中的 controller 进行自定义。我们也可以将 controller 定义成为多层的形式。

resources :photos, controller: 'api/images'
```

- 自定义 route helper

```
我们不仅可以自定义 controller，还能够自定义 route helper。
在自定义 controller 中，只有 controller#action 发生改变。
在自定义 route helper 中，只有 Route Helper 发生改变。
```

```ruby
  resources :photos, as: 'images'
  # GET /photos photos#index images_path
  # GET /photos/new photos#new new_image_path
```

- 自定义参数约束

```
我们可以对 resources 中的参数添加约束条件。下面例子中，我们不允许 id 中有 \/
```

```ruby
constraints(id: /[^\/]+/) do
  resources :photos
  resources :images
end
```

- 自定义 new/edit 的路径

```ruby
resources :photos, path_name: { new: 'make', edit: 'change' }
# GET /photos/make
# GET /photos/:id/change
```

- 指定需要创建的路由

```ruby
resources :photos, only: [:index, :show]
resources :photos, except: :destroy
```

## Inspecting Routes

```ruby
http://localhost:8000/rails/info/routes

bundle exec rails routes

# the --expanded option can show more information
bundle exec rails routes --expanded

# -g match the URL helper / HTTP Verb / URL path
bundle exec rails routes -g photos
bundle exec rails routes -g POST

# -c match the controller
bundle exec rails routes -c photos
bundle exec rails routes -c PhotosController
bundle exec rails routes -c api/photos
bundle exec rails routes -c Api::PhotosController
```
