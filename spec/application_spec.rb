require 'minitest_helper'

class TestMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'] == '/private'
      [403, {}, ['Permission denied']]
    else      
      @app.call env
    end
  end
end

class TestMap < Rasti::Web::Application
  get '/resource/:id' do |request, response, render|
    render.json id: request.params['id'].to_i
  end
end

class TestApp < Rasti::Web::Application

  use TestMiddleware

  map '/api', TestMap

  get '/' do |request, response, render|
    render.html 'Page content'
  end

  not_found do |request, response, render|
    render.status 404, 'Page not found'
  end

end

describe Rasti::Web::Application do

  include Rack::Test::Methods

  def app
    TestApp
  end

  it 'List all routes' do
    app.all_routes.must_equal 'GET' => ['/']
  end

  it 'Defined route' do
    get '/'
    
    last_response.status.must_equal 200
    last_response['Content-Type'].must_equal 'text/html; charset=utf-8'
    last_response.body.must_equal 'Page content'
  end

  it 'Not found' do
    get '/not_found'
    
    last_response.status.must_equal 404
    last_response.body.must_equal 'Page not found'
  end

  it 'Middleware' do
    get '/private'

    last_response.status.must_equal 403
    last_response.body.must_equal 'Permission denied'
  end

  it 'Map' do
    get '/api/resource/123'

    last_response.status.must_equal 200
    last_response['Content-Type'].must_equal 'application/json; charset=utf-8'
    last_response.body.must_equal '{"id":123}'
  end
  
end