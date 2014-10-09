require 'minitest_helper'

describe Rasti::Web::Router do

  let(:router) { Rasti::Web::Router.new }

  def get(path)
    Rack::MockRequest.env_for path, method: :get
  end

  def post(path)
    Rack::MockRequest.env_for path, method: :post
  end
  
  it 'Verbs' do
    %w(delete get head options patch post put).each do |verb|
      router.must_respond_to verb
    end
  end

  it 'Route matching' do
    router.get '/resources', ->(env) { :index }
    router.post '/resources/:id', ->(env) { :update }
    router.not_found ->(env) { :not_found }

    router.call(get('/resources')).must_equal :index
    router.call(post('/resources/123')).must_equal :update
    router.call(post('/resources')).must_equal :not_found
  end

  it 'Not found' do
    status, headers, response = router.call get('/not_found')

    status.must_equal 404
    response.body.must_equal ['Not found: GET /not_found']
  end

end