require 'coverage_helper'
require 'rasti-web'
require 'minitest/autorun'
require 'minitest/colorin'
require 'rack/test'
require 'pry-nav'

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

Broadcaster.configure do |config|
  config.logger = Rasti::Web.logger
end