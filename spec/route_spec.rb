require 'minitest_helper'

describe Rasti::Web::Route do

  def build_route(pattern, endpoint=:fake_endpoint)
    Rasti::Web::Route.new pattern, :fake_endpoint 
  end

  it 'Static' do
    route = build_route '/resource'

    route.pattern.must_equal '/resource'
    route.regexp.to_s.must_equal /^\/resource$/.to_s
    route.endpoint.must_equal :fake_endpoint
    route.params.must_equal []
  end

  it 'Params' do
    route = build_route '/resource/:id/:action'

    route.pattern.must_equal '/resource/:id/:action'
    route.regexp.to_s.must_equal /^\/resource\/([^\/?#]+)\/([^\/?#]+)$/.to_s
    route.endpoint.must_equal :fake_endpoint
    route.params.must_equal %w(id action)
  end

  it 'Match' do
    build_route('/').must_be :match?, '/'
    build_route('/').wont_be :match?, '/resource'
    
    build_route('/resource').must_be :match?, '/resource'
    build_route('/resource').must_be :match?, '/resource/'
    build_route('/resource').wont_be :match?, '/'

    build_route('/resource/:id/:action').must_be :match?, '/resource/123/show'
    build_route('/resource/:id/:action').wont_be :match?, '/123/show'
  end

  it 'Extract params' do
    build_route('/resource').extract_params('/resource').must_equal Hash.new
    build_route('/resource/:id/:action').extract_params('/resource/123/show').must_equal 'id' => '123', 'action' => 'show'
  end

  it 'Normalize path' do
    build_route('').pattern.must_equal '/'
    build_route('/').pattern.must_equal '/'
    build_route('/resource').pattern.must_equal '/resource'
    build_route('/resource/').pattern.must_equal '/resource'
  end

  it 'Block endpoint' do
    route = Rasti::Web::Route.new('/') do |req, res|
      res.status = 404
      res['Content-Type'] = 'text/html'
      res.write '<h1>Not found</h1>'
    end

    route.endpoint.must_be_instance_of Rasti::Web::Endpoint

    status, headers, response = route.endpoint.call(:fake_env)

    status.must_equal 404
    headers['Content-Type'].must_equal 'text/html'
    response.body.must_equal ['<h1>Not found</h1>']
  end

end