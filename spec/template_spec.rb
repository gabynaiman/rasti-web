require 'minitest_helper'

describe Rasti::Web::Template do

  class Context
    def max(var1, var2)
      [var1, var2].max
    end
  end
  
  it 'Plain HTML' do
    Rasti::Web::Template.render('plain_html').must_equal '<h1>Hello world</h1>'
  end

  it 'Context method' do
    Rasti::Web::Template.render('context_method', Context.new).must_equal '2'
  end

  it 'Local variable' do
    Rasti::Web::Template.render('local_variable', nil, text: 'Welcome').must_equal 'Welcome'
  end

  it 'Invalid template' do
    proc { Rasti::Web::Template.render 'invalid' }.must_raise RuntimeError
  end

end