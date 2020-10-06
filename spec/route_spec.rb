require 'minitest_helper'

describe Rasti::Web::Route do

  ROUTES = [
    '/',
    '/*/wildcard/action',
    '/wildcard/*/action',
    '/wildcard/*/action/:id',
    '/wildcard/*',
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
    route.extract_params(path).must_equal id: '123', action: 'show'
    route.call({}).must_equal RESPONSE
  end

  ['/other', '/other/456', '/other/456/edit'].each do |path|
    it "Optional params '#{path}'" do
      route = route_for path
      sections = path[1..-1].split('/')

      route.pattern.must_equal '/:resource(/:id(/:action))'
      route.extract_params(path).must_equal resource: sections[0], id: sections[1], action: sections[2]
      route.call({}).must_equal RESPONSE
    end
  end

  describe 'Wildcard' do
    it 'Head' do
      path = '/section/sub_section/wildcard/action'

      route = route_for path

      route.pattern.must_equal '/*/wildcard/action'
      route.extract_params(path).must_equal wildcard: 'section/sub_section'
      route.call({}).must_equal RESPONSE
    end

    it 'Middle' do
      path = '/wildcard/section/sub_section/action'

      route = route_for path

      route.pattern.must_equal '/wildcard/*/action'
      route.extract_params(path).must_equal wildcard: 'section/sub_section'
      route.call({}).must_equal RESPONSE
    end

    ['/wildcard', '/wildcard/123', '/wildcard/123/edit'].each do |path|
      it "Tail #{path}" do
        route = route_for path

        route.pattern.must_equal '/wildcard/*'
        route.extract_params(path).must_equal wildcard: path["/wildcard/".size..-1]
        route.call({}).must_equal RESPONSE
      end
    end

    it 'Params' do
      path = '/wildcard/section/sub_section/action/123'

      route = route_for path

      route.pattern.must_equal '/wildcard/*/action/:id'
      route.extract_params(path).must_equal wildcard: 'section/sub_section', id: '123'
      route.call({}).must_equal RESPONSE
    end
  end

end