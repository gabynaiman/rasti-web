# Rasti::Web

[![Gem Version](https://badge.fury.io/rb/rasti-web.svg)](https://rubygems.org/gems/rasti-web)
[![CI](https://github.com/gabynaiman/rasti-web/actions/workflows/ci.yml/badge.svg)](https://github.com/gabynaiman/rasti-web/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/gabynaiman/rasti-web/badge.svg?branch=master)](https://coveralls.io/github/gabynaiman/rasti-web?branch=master)

**Rasti::Web** is a lightweight, modular web framework built on top of [Rack](https://github.com/rack/rack). It provides essential building blocks for creating robust web applications without imposing too much structure.

## Key Features

- **Simplicity**: Minimalist and easy-to-understand API
- **Flexibility**: Direct access to Rack primitives for full control over the request/response cycle
- **Powerful rendering**: Support for multiple formats (HTML, JSON, JavaScript, CSS, files, etc.)
- **Advanced routing**: Static, parameterized, optional, and wildcard routes
- **Template system**: ERB integration for views, layouts, and partials
- **Error handling**: Hooks system and rescue_from for exception management

## Use Cases

- Building REST APIs
- Full web applications
- Microservices
- Applications requiring fine-grained control over the request/response cycle

## Installation

Add this line to your application's Gemfile:

    gem 'rasti-web'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rasti-web

## Usage

### Application

#### Basic definition

```ruby
class WebApp < Rasti::Web::Application

  get '/' do |request, response, render|
    render.html 'Welcome'
  end

end
```

#### Middleware

```ruby
class WebApp < Rasti::Web::Application

  use Rack::Session::Cookie, secret: 'my_secret'
  use SomeCustomMiddleware

  get '/private' do |request, response, render|
    render.html 'Private content'
  end

end
```

#### Mounting sub-applications

```ruby
class ApiApp < Rasti::Web::Application
  get '/resource/:id' do |request, response, render|
    render.json id: request.params['id'].to_i
  end
end

class WebApp < Rasti::Web::Application
  map '/api', ApiApp
  
  get '/' do |request, response, render|
    render.html 'Home'
  end
end
```

#### Custom not_found handler

```ruby
class WebApp < Rasti::Web::Application

  get '/' do |request, response, render|
    render.html 'Home'
  end

  not_found do |request, response, render|
    render.status 404, 'Page not found'
  end

end
```

#### Listing routes

```ruby
WebApp.all_routes
# => {'GET' => ['/'], 'POST' => ['/users']}
```

### Routing

#### HTTP Verbs

Rasti::Web supports all standard HTTP verbs:

```ruby
class WebApp < Rasti::Web::Application

  get '/resources' do |request, response, render|
    render.json resources: Resource.all
  end

  post '/resources' do |request, response, render|
    resource = Resource.create(request.params)
    render.json resource, 201
  end

  put '/resources/:id' do |request, response, render|
    resource = Resource.update(request.params[:id], request.params)
    render.json resource
  end

  patch '/resources/:id' do |request, response, render|
    resource = Resource.patch(request.params[:id], request.params)
    render.json resource
  end

  delete '/resources/:id' do |request, response, render|
    Resource.delete(request.params[:id])
    render.status 204
  end

  head '/resources/:id' do |request, response, render|
    render.status Resource.exists?(request.params[:id]) ? 200 : 404
  end

  options '/resources' do |request, response, render|
    render.status 200, 'Allow' => 'GET, POST, OPTIONS'
  end

end
```

#### Static routes

```ruby
get '/about' do |request, response, render|
  render.html 'About page'
end
```

#### Parameterized routes

```ruby
get '/users/:id' do |request, response, render|
  user = User.find(request.params[:id])
  render.json user
end

get '/posts/:post_id/comments/:id' do |request, response, render|
  comment = Comment.find(request.params[:id], post_id: request.params[:post_id])
  render.json comment
end
```

#### Optional parameters

```ruby
# Matches: /resource, /resource/123, /resource/123/edit
get '/:resource(/:id(/:action))' do |request, response, render|
  render.json(
    resource: request.params[:resource],
    id: request.params[:id],
    action: request.params[:action]
  )
end
```

#### Wildcard routes

```ruby
# Wildcard at the beginning: /*/files/download
get '/*/files/download' do |request, response, render|
  path = request.params[:wildcard]  # "users/documents"
  render.file File.join(path, 'file.zip')
end

# Wildcard in the middle: /files/*/download
get '/files/*/download' do |request, response, render|
  path = request.params[:wildcard]
  render.file File.join('files', path, 'download.zip')
end

# Wildcard at the end: /files/*
get '/files/*' do |request, response, render|
  path = request.params[:wildcard]
  render.file File.join('files', path)
end

# Wildcard with parameters: /files/*/download/:id
get '/files/*/download/:id' do |request, response, render|
  render.json(
    path: request.params[:wildcard],
    id: request.params[:id]
  )
end
```

### Controllers

#### Basic controller

```ruby
class UsersController < Rasti::Web::Controller

  def index
    users = User.all
    render.view 'users/list', users: users
  end

  def show
    user = User.find(params[:id])
    render.view 'users/show', user: user
  end

  def update
    user = User.find(params[:id])
    if user.update_attributes(params[:user])
      render.view 'users/show', user: user
    else
      render.view 'users/edit', user: user
    end
  end

end
```

#### Using controllers in routes

```ruby
class WebApp < Rasti::Web::Application

  get '/users', UsersController >> :index
  get '/users/:id', UsersController >> :show
  put '/users/:id', UsersController >> :update

end
```

#### Hooks

##### Before hooks

```ruby
class UsersController < Rasti::Web::Controller

  # Runs before all actions
  before_action do |action_name|
    authenticate_user!
  end

  # Runs before a specific action
  before_action :update do
    verify_permissions!
  end

  def update
    # action code
  end

end
```

##### After hooks

```ruby
class UsersController < Rasti::Web::Controller

  # Runs after all actions
  after_action do |action_name|
    log_action(action_name)
  end

  # Runs after a specific action
  after_action :create do
    send_notification
  end

  def create
    # action code
  end

end
```

#### Error handling

```ruby
class UsersController < Rasti::Web::Controller

  # Catch a specific exception
  rescue_from UserNotFound do |ex|
    render.status 404, ex.message
  end

  # Catch by class hierarchy (catches IOError and its subclasses like EOFError)
  rescue_from IOError do |ex|
    render.status 500, ex.message
  end

  # Multiple rescue_from
  rescue_from ValidationError do |ex|
    render.json({errors: ex.errors}, 422)
  end

  rescue_from AuthenticationError do |ex|
    render.status 401, 'Unauthorized'
  end

  def show
    user = User.find(params[:id])  # may raise UserNotFound
    render.json user
  end

end
```

### Endpoints

Endpoints can be blocks or controller actions:

```ruby
# Endpoint as a block
endpoint = Rasti::Web::Endpoint.new do |request, response, render|
  render.text 'Hello world'
end

# Endpoint from a controller
endpoint = UsersController.action :index

# Endpoints are Rack-compatible
status, headers, response = endpoint.call(env)
```

### Request

#### Accessing parameters

```ruby
get '/search' do |request, response, render|
  # Route parameters
  user_id = request.params[:user_id]
  
  # Query string parameters (?q=ruby&page=1)
  query = request.params['q']
  page = request.params[:page]
  
  # Parameters are accessible with strings or symbols
  render.json query: query, page: page
end
```

#### Form parameters

```ruby
post '/users' do |request, response, render|
  # Form parameters (POST/PUT)
  name = request.params[:name]
  email = request.params['email']
  
  user = User.create(name: name, email: email)
  render.json user
end
```

#### JSON body parameters

```ruby
post '/api/users' do |request, response, render|
  # Content-Type: application/json automatically parsed
  if request.json?
    user = User.create(request.params)
    render.json user, 201
  else
    render.status 400, 'Expected JSON content type'
  end
end
```

### Rendering

The `render` object provides multiple methods for different response formats:

#### Status codes

```ruby
# Status code only
render.status 404

# Status code and body
render.status 500, 'Internal server error'

# Status code and headers
render.status 201, 'Content-Type' => 'application/json'

# Status code, body and headers
render.status 403, 'Forbidden', 'Content-Type' => 'text/html'
```

#### Text

```ruby
# Plain text
render.text 'Hello world'

# With status code
render.text 'Not found', 404

# With headers
render.text 'Encoded text', 'Content-Encoding' => 'gzip'

# With status code and headers
render.text 'Error', 500, 'Content-Encoding' => 'gzip'
```

#### HTML

```ruby
# Basic HTML
render.html '<h1>Welcome</h1>'

# With status code
render.html '<h1>Error</h1>', 500

# With headers
render.html '<p>Content</p>', 'Content-Encoding' => 'gzip'

# With status code and headers
render.html '<h1>Not found</h1>', 404, 'Custom-Header' => 'value'
```

#### JSON

```ruby
# Object serialized to JSON
render.json id: 123, name: 'John'

# Direct JSON string
render.json '{"x":1,"y":2}'

# With status code
render.json {error: 'Invalid'}, 422

# With headers
render.json {data: []}, 'Content-Encoding' => 'gzip'

# With status code and headers
render.json {error: 'Invalid'}, 422, 'X-Error-Code' => 'VAL001'
```

#### JavaScript

```ruby
# JavaScript code
render.js 'alert("hello");'

# With status code
render.js 'console.log("loaded");', 206

# With headers
render.js 'alert("hello");', 'Content-Encoding' => 'gzip'

# With status code and headers
render.js 'alert("hello");', 206, 'Cache-Control' => 'no-cache'
```

#### CSS

```ruby
# CSS code
render.css 'body{margin:0}'

# With status code
render.css 'body{margin:0}', 206

# With headers
render.css 'body{margin:0}', 'Content-Encoding' => 'gzip'

# With status code and headers
render.css 'body{margin:0}', 206, 'Cache-Control' => 'public'
```

#### File downloads

```ruby
# File download
render.file '/path/to/file.zip'
# Content-Type and Content-Disposition are set automatically

# With status code
render.file '/path/to/file.pdf', 206

# With custom headers
render.file '/path/to/file.zip', 'Content-Disposition' => 'attachment; filename=custom.zip'

# With status code and headers
render.file '/path/to/file.zip', 206, 'Content-Disposition' => 'attachment; filename=custom.zip'
```

#### Data with headers

```ruby
# Data without Content-Type
render.data 'Raw content'

# With status code
render.data 'Content', 206

# With headers (useful with Rasti::Web::Headers.for_file)
render.data file_content, Rasti::Web::Headers.for_file('document.txt')

# With status code and headers
render.data content, 206, Rasti::Web::Headers.for_file('file.txt')
```

### Templates

Rasti::Web uses ERB for templates. By default, it looks for templates in `views/`.

#### Configuring views directory

```ruby
# Configure template directory (default: 'views')
Rasti::Web::Template.template_path = '/path/to/templates'
```

#### Partials

Partials are templates without layout:

```ruby
# views/users/_user_info.erb
<h1><%= title %></h1>
<div><%= text %></div>

# In your endpoint/controller:
render.partial 'users/user_info', title: 'Welcome', text: 'Hello world'
# => <h1>Welcome</h1><div>Hello world</div>
```

#### Layouts

```ruby
# views/layout.erb
<html><body><%= yield %></body></html>

# Layout with content
render.layout { 'Page content' }
# => <html><body>Page content</body></html>

# Empty layout
render.layout
# => <html><body></body></html>
```

#### Custom layouts

```ruby
# views/custom_layout.erb
<html><body class="custom"><%= yield %></body></html>

# Use custom layout
render.layout('custom_layout') { 'Page content' }
# => <html><body class="custom">Page content</body></html>
```

#### Views

Views combine a template with a layout:

```ruby
# views/users/profile.erb
<h1><%= title %></h1>
<div><%= text %></div>

# views/layout.erb
<html><body><%= yield %></body></html>

# With default layout (layout.erb)
render.view 'users/profile', title: 'Welcome', text: 'Hello world'
# => <html><body><h1>Welcome</h1><div>Hello world</div></body></html>

# With custom layout
render.view 'users/profile', {title: 'Welcome', text: 'Hello'}, 'custom_layout'
```

#### Context methods and local variables

```ruby
# Module with context methods
module ViewHelpers
  def format_date(date)
    date.strftime('%Y-%m-%d')
  end
end

# views/posts/show.erb using context method
<h1><%= format_date(post.created_at) %></h1>

# Render with context
class PostContext
  include ViewHelpers
end

render.partial 'posts/show', PostContext.new, post: post

# Or use local variables directly
render.partial 'posts/show', title: 'My Post', text: 'Content'
```

## Advanced Usage

### Complete example

```ruby
# app.rb
class AuthController < Rasti::Web::Controller
  
  def login
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      render.json user
    else
      render.status 401, 'Invalid credentials'
    end
  rescue AuthenticationError => ex
    render.status 401, ex.message
  end

end

class UsersController < Rasti::Web::Controller

  before_action do |action_name|
    authenticate_user!
  end

  rescue_from UserNotFound do |ex|
    render.status 404, ex.message
  end

  def index
    users = User.all
    render.view 'users/index', users: users
  end

  def show
    user = User.find(params[:id])
    render.view 'users/show', user: user
  end

  private

  def authenticate_user!
    unless session[:user_id]
      render.status 401, 'Unauthorized'
    end
  end

end

class WebApp < Rasti::Web::Application

  use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']

  # Public routes
  post '/login', AuthController >> :login

  # Protected routes
  get '/users', UsersController >> :index
  get '/users/:id', UsersController >> :show

  # API mount
  map '/api', ApiApp

  # Custom not found
  not_found do |request, response, render|
    render.view '404', path: request.path_info
  end

end

# config.ru
require_relative 'app'
run WebApp
```

## Contributing

1. Fork it ( https://github.com/gabynaiman/rasti-web/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
