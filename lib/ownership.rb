require "ownership/global_methods"
require "ownership/honeybadger"
require "ownership/rollbar"
require "ownership/version"

module Ownership
  class << self
    attr_accessor :default_owner
    attr_accessor :around_change

    def owner
      Thread.current[:ownership_owner] || default_owner
    end
  end
end

Object.send :include, Ownership::GlobalMethods

if defined?(ActiveSupport)
  ActiveSupport.on_load(:action_controller) do
    require "ownership/controller_methods"
    include Ownership::ControllerMethods
  end

  ActiveSupport.on_load(:active_record) do
    require "ownership/marginalia" if defined?(Marginalia)
  end

  ActiveSupport.on_load(:active_job) do
    require "ownership/job_methods"
    include Ownership::JobMethods
  end
else
  require "ownership/marginalia" if defined?(Marginalia)
end

class Exception
  attr_accessor :owner
end
