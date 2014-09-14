require 'rack'
require 'tilt'
require 'json'
require 'class_config'
require 'forwardable'

require_relative 'web/route'
require_relative 'web/router'
require_relative 'web/endpoint'
require_relative 'web/application'
require_relative 'web/template'
require_relative 'web/view_context'
require_relative 'web/render'
require_relative 'web/controller'
require_relative 'web/version'

module Rasti
  module Web
    PATH_PARAMS = 'rack.request.path_params'

    extend ClassConfig

    attr_config :views_path, File.join(Dir.pwd, 'views')
    attr_config :template_engines, [:erb]
    attr_config :default_layout, 'layout'
    attr_config :helpers, []

    after_config do |config|
      config.helpers.each { |h| ViewContext.send :include, h }
    end
  end
end