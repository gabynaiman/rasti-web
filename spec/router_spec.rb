require 'minitest_helper'

describe Rasti::Web::Router do

  let(:router) { Rasti::Web::Router.new }
  
  it 'Verbs' do
    %w(delete get head options patch post put).each do |verb|
      router.must_respond_to verb
    end
  end

  it 'Route matching' do
    router.get '/resources', :index_endpoint
    router.post '/resources/:id', :update_endpoint
    router.not_found :not_found_endpoint

    router.route_for('GET', '/resources').tap do |route|
      route.must_be_instance_of Rasti::Web::Route
      route.endpoint.must_equal :index_endpoint
    end
    
    router.route_for('POST', '/resources/123').tap do |route|
      route.must_be_instance_of Rasti::Web::Route
      route.endpoint.must_equal :update_endpoint
    end

    router.route_for('POST', '/resources').tap do |route|
      route.must_be_instance_of Rasti::Web::Route
      route.endpoint.must_equal :not_found_endpoint
    end
  end

  it 'Not found' do
    route = router.route_for 'GET', '/not_found'
    status, headers, response = route.endpoint.call Rack::MockRequest.env_for('/not_found')

    status.must_equal 404
    response.body.must_equal ['Not found: GET /not_found']
  end

end