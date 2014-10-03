require 'minitest_helper'

describe Rasti::Web::Endpoint do

  it 'Call' do
    endpoint = Rasti::Web::Endpoint.new do |req, res, render|
      req.must_be_instance_of Rasti::Web::Request
      res.must_be_instance_of Rack::Response

      render.text 'Content'
    end    

    env = Rack::MockRequest.env_for '/'

    status, headers, response = endpoint.call env

    status.must_equal 200
    headers['Content-Type'].must_equal 'text/plain'
    response.body.must_equal ['Content']
  end

end