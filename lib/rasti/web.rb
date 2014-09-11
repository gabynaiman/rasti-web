require 'rack'
require 'tilt'
require 'json'
require 'class_config'
require 'forwardable'

require_relative 'web/route'
require_relative 'web/router'
require_relative 'web/endpoint'
require_relative 'web/application'
require_relative 'web/render'
require_relative 'web/parameters'
require_relative 'web/controller'
require_relative 'web/version'

module Rasti
  module Web
    extend ClassConfig

    attr_config :views_path, File.join(Dir.pwd, 'views')
    attr_config :template_engines, [:erb]
    attr_config :default_layout, 'layout'
  end
end