require 'minitest_helper'

class TestController < Rasti::Web::Controller

  CustomError = Class.new StandardError

  def self.hooks_log
    @hooks_log ||= []
  end

  before_action do |action_name|
    self.class.hooks_log << "Before all: #{action_name}"
  end

  after_action do |action_name|
    self.class.hooks_log << "After all: #{action_name}"
  end

  before_action :test do
    self.class.hooks_log << 'Before single: test'
  end

  after_action :test do
    self.class.hooks_log << 'After single: test'
  end

  def test
    render.html 'Test HTML'
  end

  def exception
    raise 'Unexpected error'
  end

  def explicit_fail
    raise CustomError, 'Explicit error'
  end

  def implicit_fail
    raise EOFError, 'Implicit error'
  end

  rescue_from CustomError do |ex|
    render.status 500, ex.message
  end

  rescue_from IOError do |ex|
    render.status 500, ex.message
  end

end

describe Rasti::Web::Controller do

  before do
    TestController.hooks_log.clear
  end

  it 'Action endpoint' do
    action = TestController.action :test
    env = Rack::MockRequest.env_for '/test'
    status, headers, response = action.call env

    action.must_be_instance_of Rasti::Web::Endpoint
    status.must_equal 200
    headers['Content-Type'].must_equal 'text/html; charset=utf-8'
    response.body.must_equal ['Test HTML']

    TestController.hooks_log.must_equal [
      'Before single: test',
      'After single: test'
    ]
  end

  it 'Invalid action' do
    error = proc { TestController.action :invalid }.must_raise RuntimeError
    error.message.must_equal "Undefined action 'invalid' in TestController"
    TestController.hooks_log.must_be_empty
  end

  it 'Rescue explicit exception' do
    action = TestController.action :explicit_fail
    env = Rack::MockRequest.env_for '/explicit_fail'
    status, headers, response = action.call env

    status.must_equal 500
    headers['Content-Type'].must_be_nil
    response.body.must_equal ['Explicit error']

    TestController.hooks_log.must_equal [
      'Before all: explicit_fail',
      'After all: explicit_fail'
    ]
  end

  it 'Rescue implicit exception' do
    action = TestController.action :implicit_fail
    env = Rack::MockRequest.env_for '/implicit_fail'
    status, headers, response = action.call env

    status.must_equal 500
    headers['Content-Type'].must_be_nil
    response.body.must_equal ['Implicit error']

    TestController.hooks_log.must_equal [
      'Before all: implicit_fail',
      'After all: implicit_fail'
    ]
  end

  it 'Unexpected exception' do
    action = TestController.action :exception
    env = Rack::MockRequest.env_for '/exception'

    error = proc { action.call env }.must_raise RuntimeError
    error.message.must_equal 'Unexpected error'

    TestController.hooks_log.must_equal [
      'Before all: exception',
      'After all: exception'
    ]
  end

end