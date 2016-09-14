# Rasti::Web

[![Gem Version](https://badge.fury.io/rb/rasti-web.svg)](https://rubygems.org/gems/rasti-web)
[![Build Status](https://travis-ci.org/gabynaiman/rasti-web.svg?branch=master)](https://travis-ci.org/gabynaiman/rasti-web)
[![Coverage Status](https://coveralls.io/repos/gabynaiman/rasti-web/badge.svg?branch=master)](https://coveralls.io/r/gabynaiman/rasti-web?branch=master)
[![Code Climate](https://codeclimate.com/github/gabynaiman/rasti-web.svg)](https://codeclimate.com/github/gabynaiman/rasti-web)
[![Dependency Status](https://gemnasium.com/gabynaiman/rasti-web.svg)](https://gemnasium.com/gabynaiman/rasti-web)

Web blocks to build robust applications

## Installation

Add this line to your application's Gemfile:

    gem 'rasti-web'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rasti-web

## Usage

### Routing

```ruby
# app.rb
class WebApp < Rasti::Web::Application

  use SomeMiddleware

  get '/hello' do |request, response, render|
    render.text 'world'
  end

  put '/users/:id', UsersController >> :update

end

# configu.ru
require_relative 'app'
run WebApp
```

### Controllers

```ruby
class UsersController < Rasti::Web::Controller

  def update
    user = User.find(params[:id])
    if user.update_attributes(params[:user])
      render.view 'users/list', users: User.all
    else
      render.view 'users/edit', user: user
    end
  end

end
```

## Contributing

1. Fork it ( https://github.com/gabynaiman/rasti-web/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
