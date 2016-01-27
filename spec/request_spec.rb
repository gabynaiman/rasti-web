require 'minitest_helper'

describe Rasti::Web::Request do
  
  it 'Route params' do
    env = Rack::MockRequest.env_for '/10/20'
    env[Rasti::Web::ROUTE_PARAMS] = {'lat' => '10', 'lon' => '20'}

    request = Rasti::Web::Request.new env

    request.params[:lat].must_equal '10'
    request.params['lon'].must_equal '20'
  end

  it 'Query string params' do
    env = Rack::MockRequest.env_for '/?lat=10&lon=20'

    request = Rasti::Web::Request.new env

    request.params[:lat].must_equal '10'
    request.params['lon'].must_equal '20'
  end

  it 'Form params' do
    env = Rack::MockRequest.env_for '/', method: 'POST', params: 'lat=10&lon=20'

    request = Rasti::Web::Request.new env

    request.params[:lat].must_equal '10'
    request.params['lon'].must_equal '20'
  end

  it 'Json body params' do
    env = Rack::MockRequest.env_for '/', input: '{"lat": 10, "lon": 20}', 'CONTENT_TYPE' => 'application/json'

    request = Rasti::Web::Request.new env

    request.must_be :json?
    request.params[:lat].must_equal 10
    request.params['lon'].must_equal 20
  end

  it 'No json body params' do
    env = Rack::MockRequest.env_for '/', input: '{"lat": 10, "lon": 20}', 'CONTENT_TYPE' => 'other/type'

    request = Rasti::Web::Request.new env

    request.wont_be :json?
    request.params[:lat].must_be_nil
    request.params['lon'].must_be_nil
  end

end