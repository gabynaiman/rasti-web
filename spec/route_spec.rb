require 'minitest_helper'

describe Rasti::Web::Route do

  ROUTES = [
    '/', 
    '/resource', 
    '/resource/:id/:action',
    '/:resource(/:id(/:action))'
  ]

  RESPONSE = [200, {}, []]

  def build_route(pattern)
    Rasti::Web::Route.new pattern, ->(env) { RESPONSE }
  end

  def route_for(path)
    ROUTES.map    { |r| build_route r }
          .detect { |r| r.match? path }
  end

  ['', '/'].each do |path|
    it "Root '#{path}'" do
      route = route_for path

      route.pattern.must_equal '/'
      route.extract_params(path).must_be_empty
      route.call({}).must_equal RESPONSE
    end
  end

  ['/resource', '/resource/'].each do |path|
    it "Static '#{path}'" do
      route = route_for path

      route.pattern.must_equal '/resource'
      route.extract_params(path).must_be_empty
      route.call({}).must_equal RESPONSE
    end
  end

  it 'Params' do
    path = '/resource/123/show'
    route = route_for path

    route.pattern.must_equal '/resource/:id/:action'
    route.extract_params(path).must_equal 'id' => '123', 'action' => 'show'
    route.call({}).must_equal RESPONSE
  end

  ['/other', '/other/456', '/other/456/edit'].each do |path|
    it "Optional params '#{path}'" do
      route = route_for path
      sections = path[1..-1].split('/')

      route.pattern.must_equal '/:resource(/:id(/:action))'
      route.extract_params(path).must_equal 'resource' => sections[0], 'id' => sections[1], 'action' => sections[2]
      route.call({}).must_equal RESPONSE
    end
  end

end