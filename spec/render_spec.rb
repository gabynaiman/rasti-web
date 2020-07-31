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
      response['Content-Type'].must_equal 'text/plain; charset=utf-8'
      response.body.must_equal ['Plain text']
    end

    it 'Body and status' do
      render.text 'Internal server error', 500

      response.status.must_equal 500
      response['Content-Type'].must_equal 'text/plain; charset=utf-8'
      response.body.must_equal ['Internal server error']
    end

    it 'Body and headers' do
      render.text 'Encoded text', 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/plain; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['Encoded text']
    end

    it 'Body, status and headers' do
      render.text 'Not found', 404, 'Content-Encoding' => 'gzip'

      response.status.must_equal 404
      response['Content-Type'].must_equal 'text/plain; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['Not found']
    end

  end

  describe 'HTML' do

    it 'Body' do
      render.html '<h1>Title</h1>'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_equal ['<h1>Title</h1>']
    end

    it 'Body and status' do
      render.html '<h1>Internal server error</h1>', 500

      response.status.must_equal 500
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_equal ['<h1>Internal server error</h1>']
    end

    it 'Body and headers' do
      render.html '<p>Encoded text</p>', 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['<p>Encoded text</p>']
    end

    it 'Body, status and headers' do
      render.html '<h1>Not found</h1>', 404, 'Content-Encoding' => 'gzip'

      response.status.must_equal 404
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['<h1>Not found</h1>']
    end

  end

  describe 'Json' do

    let(:object) { {id: 123, color: 'red'} }

    it 'Body' do
      render.json object

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response.body.must_equal [object.to_json]
    end

    it 'Body string' do
      render.json '{"x":1,"y":2}'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response.body.must_equal ['{"x":1,"y":2}']
    end

    it 'Body and status' do
      render.json object, 422

      response.status.must_equal 422
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response.body.must_equal [object.to_json]
    end

    it 'Body and headers' do
      render.json object, 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal [object.to_json]
    end

    it 'Body, status and headers' do
      render.json object, 422, 'Content-Encoding' => 'gzip'

      response.status.must_equal 422
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal [object.to_json]
    end

  end

  describe 'Javascript' do
    
    it 'Body' do
      render.js 'alert("hello");'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/javascript; charset=utf-8'
      response.body.must_equal ['alert("hello");']
    end

    it 'Body and status' do
      render.js 'alert("hello");', 206

      response.status.must_equal 206
      response['Content-Type'].must_equal 'application/javascript; charset=utf-8'
      response.body.must_equal ['alert("hello");']
    end

    it 'Body and headers' do
      render.js 'alert("hello");', 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/javascript; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['alert("hello");']
    end

    it 'Body, status and headers' do
      render.js 'alert("hello");', 206, 'Content-Encoding' => 'gzip'

      response.status.must_equal 206
      response['Content-Type'].must_equal 'application/javascript; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['alert("hello");']
    end

  end

  describe 'CSS' do
    
    it 'Body' do
      render.css 'body{margin:0}'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/css; charset=utf-8'
      response.body.must_equal ['body{margin:0}']
    end

    it 'Body and status' do
      render.css 'body{margin:0}', 206

      response.status.must_equal 206
      response['Content-Type'].must_equal 'text/css; charset=utf-8'
      response.body.must_equal ['body{margin:0}']
    end

    it 'Body and headers' do
      render.css 'body{margin:0}', 'Content-Encoding' => 'gzip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/css; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['body{margin:0}']
    end

    it 'Body, status and headers' do
      render.css 'body{margin:0}', 206, 'Content-Encoding' => 'gzip'

      response.status.must_equal 206
      response['Content-Type'].must_equal 'text/css; charset=utf-8'
      response['Content-Encoding'].must_equal 'gzip'
      response.body.must_equal ['body{margin:0}']
    end

  end

  describe 'File' do

    let(:filename) { File.expand_path '../sample_file.zip', __FILE__ }

    it 'Body' do
      render.file filename

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/zip'
      response.body.must_equal [File.read(filename)]
    end

    it 'Body and status' do
      render.file filename, 206

      response.status.must_equal 206
      response['Content-Type'].must_equal 'application/zip'
      response.body.must_equal [File.read(filename)]
    end

    it 'Body and headers' do
      render.file filename, 'Content-Disposition' => 'attachment; filename=test_file.zip'

      response.status.must_equal 200
      response['Content-Type'].must_equal 'application/zip'
      response['Content-Disposition'].must_equal 'attachment; filename=test_file.zip'
      response.body.must_equal [File.read(filename)]
    end

    it 'Body, status and headers' do
      render.file filename, 206, 'Content-Disposition' => 'attachment; filename=test_file.zip'

      response.status.must_equal 206
      response['Content-Type'].must_equal 'application/zip'
      response['Content-Disposition'].must_equal 'attachment; filename=test_file.zip'
      response.body.must_equal [File.read(filename)]
    end

  end

  it 'Partial' do
    render.partial 'context_and_locals', title: 'Welcome', text: 'Hello world'

    response.status.must_equal 200
    response['Content-Type'].must_equal 'text/html; charset=utf-8'
    response.body.must_equal ['<h1>Welcome</h1><div>Hello world</div>']
  end

  describe 'Layout' do
    
    it 'Default' do
      render.layout { 'Page content' }

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_equal ['<html><body>Page content</body></html>']
    end

    it 'Custom' do
      render.layout('custom_layout') { 'Page content' }

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_equal ['<html><body class="custom">Page content</body></html>']
    end

    it 'Empty' do
      render.layout

      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_equal ['<html><body></body></html>']
    end

  end

  describe 'View' do

    it 'Default layout' do
      render.view 'context_and_locals', title: 'Welcome', text: 'Hello world'
      
      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_equal ['<html><body><h1>Welcome</h1><div>Hello world</div></body></html>']
    end

    it 'Custom layout' do
      render.view 'context_and_locals', {title: 'Welcome', text: 'Hello world'}, 'custom_layout'
      
      response.status.must_equal 200
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_equal ['<html><body class="custom"><h1>Welcome</h1><div>Hello world</div></body></html>']
    end

  end

  describe 'Char stream' do

    let(:string) { 'Imagine this is a multi-megabyte text.' }

    it 'Empty' do
      render.char_stream ''

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal []
    end

    it 'Body' do
      render.char_stream string

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        string
      ]
    end

    it 'Body and headers' do
      render.char_stream string, 'Content-Type' => 'text/html; charset=utf-8'

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        string
      ]
    end

    it 'Body, headers and chunk size' do
      render.char_stream string, {'Content-Type' => 'text/html; charset=utf-8'}, 10

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        'Imagine th',
        'is is a mu',
        'lti-megaby',
        'te text.'
      ]
    end

  end

  describe 'Json object stream' do

    let(:object) { {id: 123, color: 'red', size: 'XXL'} }

    it 'Empty' do
      render.json_object_stream({})

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        {}.to_json
      ]
    end

    it 'Body' do
      render.json_object_stream object

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        object.to_json
      ]
    end

    it 'Body and headers' do
      render.json_object_stream object, 'Connection' => 'keep-alive'

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response['Connection'].must_equal 'keep-alive'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        object.to_json
      ]
    end

    it 'Body, headers and chunk size' do
      render.json_object_stream object, {'Connection' => 'keep-alive'}, 10

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response['Connection'].must_equal 'keep-alive'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        '{"id":123,',
        '"color":"r',
        'ed","size"',
        ':"XXL"}'
      ]
    end

  end

  describe 'Json array stream' do

    let(:array) { [{id: 123, color: 'red', size: 'XXL'}, {id: 456, color: 'green', size: 'XXXL'}] }

    it 'Empty' do
      render.json_array_stream []

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        [].to_json
      ]
    end

    it 'Body' do
      render.json_array_stream array

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        "[#{array[0].to_json}",
        ",#{array[1].to_json}",
        "]"
      ]
    end

    it 'Body and headers' do
      render.json_array_stream array, 'Connection' => 'keep-alive'

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response['Connection'].must_equal 'keep-alive'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        "[#{array[0].to_json}",
        ",#{array[1].to_json}",
        "]"
      ]
    end

    it 'Body, headers and chunk size' do
      render.json_array_stream array, {'Connection' => 'keep-alive'}, 10

      response.status.must_equal 200
      response['X-Accel-Buffering'] = 'no'
      response['Cache-Control'] = 'no-cache'
      response['Content-Type'].must_equal 'application/json; charset=utf-8'
      response['Connection'].must_equal 'keep-alive'
      response.body.must_be_instance_of Enumerator
      chunks = response.body.to_a
      chunks.must_equal [
        '[{"id":123',
        ',"color":"',
        'red","size',
        '":"XXL"}',
        ',{"id":456',
        ',"color":"',
        'green","si',
        'ze":"XXXL"',
        '}',
        ']'
      ]
    end

  end

end