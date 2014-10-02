require 'minitest_helper'

describe Rasti::Web::Endpoint do

  it 'No params' do
    endpoint = Rasti::Web::Endpoint.new do |req, res, render|
      render.text 'Welcome'
    end

    status, headers, response = endpoint.call Rack::MockRequest.env_for('/')

    status.must_equal 200
    headers['Content-Type'].must_equal 'text/plain'
    response.body.must_equal ['Welcome']
  end
  
  it 'Params -> Query string' do
    endpoint = Rasti::Web::Endpoint.new do |req, res, render|
      render.text "Welcome #{req.params['name']}"
    end

    status, headers, response = endpoint.call Rack::MockRequest.env_for('/?name=John')

    status.must_equal 200
    headers['Content-Type'].must_equal 'text/plain'
    response.body.must_equal ['Welcome John']
  end

  it 'Params -> Form' do
    endpoint = Rasti::Web::Endpoint.new do |req, res, render|
      render.text "Welcome #{req.params['name']}"
    end

    status, headers, response = endpoint.call Rack::MockRequest.env_for('/', method: 'POST', params: {'name' => 'John'})

    status.must_equal 200
    headers['Content-Type'].must_equal 'text/plain'
    response.body.must_equal ['Welcome John']
  end


end