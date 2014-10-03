require 'minitest_helper'

describe Rasti::Web::Request do
  
  it 'Route params' do
    env = Rack::MockRequest.env_for '/'
    env[Rasti::Web::ROUTE_PARAMS] = {'x' => 1, 'y' => 2}

    request = Rasti::Web::Request.new env

    request['x'].must_equal 1
    request['y'].must_equal 2
  end

  it 'Json body params' do
    env = Rack::MockRequest.env_for '/', input: '{"lat": 10, "lon": 20}', 'CONTENT_TYPE' => 'application/json'

    request = Rasti::Web::Request.new env

    request.must_be :json?
    request['lat'].must_equal 10
    request['lon'].must_equal 20
  end

  it 'No json body params' do
    env = Rack::MockRequest.env_for '/', input: '{"lat": 10, "lon": 20}', 'CONTENT_TYPE' => 'other/type'

    request = Rasti::Web::Request.new env

    request.wont_be :json?
    request['lat'].must_be_nil
    request['lon'].must_be_nil
  end

end