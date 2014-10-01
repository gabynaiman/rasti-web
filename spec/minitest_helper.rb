require 'coverage_helper'
require 'rasti-web'
require 'minitest/autorun'
require 'turn'

Turn.config do |c|
  c.format = :pretty
  c.natural = true
  c.ansi = true
end

Rasti::Web.configure do |config|
  config.views_path = File.expand_path '../views', __FILE__
end