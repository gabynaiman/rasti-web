require 'minitest_helper'

describe Rasti::Web::Render do

  let(:request) { Rack::Request.new Hash.new }
  let(:response) { Rack::Response.new }
  let(:render) { Rasti::Web::Render.new request, response }

  describe 'Status' do

    it 'Code' do
      render.status 404
      
      response.status.must_equal 404
      response['Content-Type'].must_be_nil
      response.body.must_equal []
    end

    it 'Code and body' do
      render.status 500, 'Internal server error'
      
      response.status.must_equal 500
      response['Content-Type'].must_be_nil
      response.body.must_equal ['Internal server error']
    end

    it 'Code and headers' do
      render.status 201, 'Content-Type' => 'application/json'

      response.status.must_equal 201
      response['Content-Type'].must_equal 'application/json'
      response.body.must_equal []
    end

    it 'Code, body and headers' do
      render.status 403, 'Forbidden', 'Content-Type' => 'text/html'

      response.status.must_equal 403
      response['Content-Type'].must_equal 'text/html'
      response.body.must_equal ['Forbidden']
    end

  end

  describe 'Text' do

    it 'Body' do
      render.text 'Plain text'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/plain'
      response.body.must_equal ['Plain text']
    end

    it 'Body and status' do
      render.text 'Internal server error', 500

      response.status.must_equal 500
      response['Content-Type'].must_equal 'text/plain'
      response.body.must_equal ['Internal server error']
    end

    it 'Body and headers' do
      render.text 'Encoded text', 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/plain'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['Encoded text']
    end

    it 'Body, status and headers' do
      render.text 'Not found', 404, 'Content-Encoding' => 'gzip'

      response.status.must_equal 404
      response['Content-Type'].must_equal 'text/plain'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['Not found']
    end

  end

  describe 'HTML' do

    it 'Body' do
      render.html '<h1>Title</h1>'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html'
      response.body.must_equal ['<h1>Title</h1>']
    end

    it 'Body and status' do
      render.html '<h1>Internal server error</h1>', 500

      response.status.must_equal 500
      response['Content-Type'].must_equal 'text/html'
      response.body.must_equal ['<h1>Internal server error</h1>']
    end

    it 'Body and headers' do
      render.html '<p>Encoded text</p>', 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['<p>Encoded text</p>']
    end

    it 'Body, status and headers' do
      render.html '<h1>Not found</h1>', 404, 'Content-Encoding' => 'gzip'

      response.status.must_equal 404
      response['Content-Type'].must_equal 'text/html'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['<h1>Not found</h1>']
    end

  end

  describe 'Json' do

    let(:object) { {id: 123, color: 'red'} }

    it 'Body' do
      render.json object

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/json'
      response.body.must_equal [object.to_json]
    end

    it 'Body string' do
      render.json '{"x":1,"y":2}'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/json'
      response.body.must_equal ['{"x":1,"y":2}']
    end

    it 'Body and status' do
      render.json object, 422

      response.status.must_equal 422
      response['Content-Type'].must_equal 'application/json'
      response.body.must_equal [object.to_json]
    end

    it 'Body and headers' do
      render.json object, 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/json'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal [object.to_json]
    end

    it 'Body, status and headers' do
      render.json object, 422, 'Content-Encoding' => 'gzip'

      response.status.must_equal 422
      response['Content-Type'].must_equal 'application/json'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal [object.to_json]
    end

  end

  describe 'Javascript' do
    
    it 'Body' do
      render.js 'alert("hello");'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/javascript'
      response.body.must_equal ['alert("hello");']
    end

    it 'Body and status' do
      render.js 'alert("hello");', 206

      response.status.must_equal 206
      response['Content-Type'].must_equal 'application/javascript'
      response.body.must_equal ['alert("hello");']
    end

    it 'Body and headers' do
      render.js 'alert("hello");', 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/javascript'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['alert("hello");']
    end

    it 'Body, status and headers' do
      render.js 'alert("hello");', 206, 'Content-Encoding' => 'gzip'

      response.status.must_equal 206
      response['Content-Type'].must_equal 'application/javascript'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['alert("hello");']
    end

  end

  it 'Partial' do
    render.partial 'context_and_locals', title: 'Welcome', text: 'Hello world'

    response.status.must_equal 200
    response['Content-Type'].must_equal 'text/html'
    response.body.must_equal ['<h1>Welcome</h1><div>Hello world</div>']
  end

  describe 'View' do

    it 'Default layout' do
      render.view 'context_and_locals', title: 'Welcome', text: 'Hello world'
      
      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html'
      response.body.must_equal ['<html><body><h1>Welcome</h1><div>Hello world</div></body></html>']
    end

    it 'Custom layout' do
      render.view 'context_and_locals', {title: 'Welcome', text: 'Hello world'}, 'custom_layout'
      
      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html'
      response.body.must_equal ['<html><body class="custom"><h1>Welcome</h1><div>Hello world</div></body></html>']
    end

  end

end