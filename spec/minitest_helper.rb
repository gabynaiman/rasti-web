require 'coverage_helper'
require 'rasti-web'
require 'minitest/autorun'
require 'turn'
require 'rack/test'
require 'pry-nav'

Turn.config do |c|
  c.format = :pretty
  c.natural = true
  c.ansi = true
end

module ContextMethodHelper
  def page_header(text)
    "<h1>#{text}</h1>"
  end
end

Rasti::Web.configure do |config|
  config.views_path = File.expand_path '../views', __FILE__
  config.helpers << ContextMethodHelper
  config.logger.level = Logger::ERROR
end