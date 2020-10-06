require 'minitest_helper'

describe Rasti::Web::Template do

  class Context
    include ContextMethodHelper
  end

  it 'Plain HTML' do
    Rasti::Web::Template.render('plain_html').must_equal '<div>Hello world</div>'
  end

  it 'Context method' do
    Rasti::Web::Template.render('context_method', Context.new).must_equal '<h1>Hello world</h1>'
  end

  it 'Local variable' do
    Rasti::Web::Template.render('local_variable', nil, text: 'Welcome').must_equal '<h1>Welcome</h1>'
  end

  it 'Invalid template' do
    proc { Rasti::Web::Template.render 'invalid' }.must_raise RuntimeError
  end

  it 'Nested' do
    Rasti::Web::Template.render('layout') { 'inner text' }.must_equal '<html><body>inner text</body></html>'
  end

end