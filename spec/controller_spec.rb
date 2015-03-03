require 'minitest_helper'

class TestController < Rasti::Web::Controller
  CustomError = Class.new StandardError
  
  def test
    render.html 'Test HTML'
  end

  def exception
    raise 'Unexpected error'
  end

  def fail
    raise CustomError, 'Expected error'
  end

  rescue_from CustomError do |ex|
    render.status 500, ex.message
  end
end

describe Rasti::Web::Controller do
  
  it 'Action endpoint' do
    action = TestController.action :test
    env = Rack::MockRequest.env_for '/test'
    status, headers, response = action.call env

    action.must_be_instance_of Rasti::Web::Endpoint
    status.must_equal 200
    headers['Content-Type'].must_equal 'text/html; charset=utf-8'
    response.body.must_equal ['Test HTML']
  end

  it 'Invalid action' do
    error = proc { TestController.action :invalid }.must_raise RuntimeError
    error.message.must_equal "Undefined action 'invalid' in TestController"
  end

  it 'Rescue exception' do
    action = TestController.action :fail
    env = Rack::MockRequest.env_for '/fail'
    status, headers, response = action.call env

    status.must_equal 500
    response.body.must_equal ['Expected error']
  end

  it 'Unexpected exception' do
    action = TestController.action :exception
    env = Rack::MockRequest.env_for '/exception'
    
    error = proc { action.call env }.must_raise RuntimeError
    error.message.must_equal 'Unexpected error'
  end

end