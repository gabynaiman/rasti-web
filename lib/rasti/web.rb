require 'rack'
require 'tilt'
require 'json'
require 'mime-types'
require 'content-type'
require 'class_config'
require 'forwardable'
require 'logger'
require 'hash_ext'
require 'restruct'

require_relative 'web/route'
require_relative 'web/router'
require_relative 'web/endpoint'
require_relative 'web/application'
require_relative 'web/template'
require_relative 'web/view_context'
require_relative 'web/render'
require_relative 'web/request'
require_relative 'web/controller'
require_relative 'web/channel'
require_relative 'web/stream'
require_relative 'web/server_sent_event'
require_relative 'web/version'

module Rasti
  module Web
    ROUTE_PARAMS = 'rack.request.route_params'

    extend ClassConfig

    attr_config :views_path, File.join(Dir.pwd, 'views')
    attr_config :template_engines, [:erb]
    attr_config :default_layout, 'layout'
    attr_config :helpers, []
    attr_config :logger, Logger.new(STDOUT)
    attr_config :channels_prefix, Restruct::Id['rasti-web']['channels']

    after_config do |config|
      config.helpers.each { |h| ViewContext.send :include, h }
    end
  end
end