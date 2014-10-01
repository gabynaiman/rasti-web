require 'minitest_helper'

describe Rasti::Web::Render do

  let(:request) { Rack::Request.new Hash.new }
  let(:response) { Rack::Response.new }
  let(:render) { Rasti::Web::Render.new request, response }

  it 'status' do
    render.status 404
    response.status.must_equal 404
    response.headers.must_be :empty?
    response.body.must_be :empty?
  end

  it 'text' do
    render.text 'Plain text'
    response.status.must_equal 200
    response.headers['Content-Type'].must_equal 'text/plain'
    response.body.must_equal ['Plain text']
  end

  it 'html' do
    render.html '<h1>Title</h1>'
    response.status.must_equal 200
    response.headers['Content-Type'].must_equal 'text/html'
    response.body.must_equal ['<h1>Title</h1>']
  end

  it 'json' do
    render.json id: 123, color: 'red'
    response.status.must_equal 200
    response.headers['Content-Type'].must_equal 'application/json'
    response.body.must_equal ['{"id":123,"color":"red"}']
  end

  it 'js' do
    render.js 'alert("hello");'
    response.status.must_equal 200
    response.headers['Content-Type'].must_equal 'application/javascript'
    response.body.must_equal ['alert("hello");']
  end

  it 'partial'

  it 'view'

end