# modules
require_relative "ownership/global_methods"
require_relative "ownership/version"

# integrations
require_relative "ownership/honeybadger"
require_relative "ownership/rollbar"

module Ownership
  class << self
    attr_accessor :around_change, :default_owner

    def owner
      Thread.current[:ownership_owner] || default_owner
    end
  end
end

Object.include Ownership::GlobalMethods

if defined?(ActiveSupport)
  ActiveSupport.on_load(:action_controller) do
    require_relative "ownership/controller_methods"
    include Ownership::ControllerMethods
  end

  ActiveSupport.on_load(:active_record) do
    if ActiveRecord::VERSION::MAJOR >= 7
      # taggings is frozen in Active Record 8
      if !ActiveRecord::QueryLogs.taggings[:owner]
        ActiveRecord::QueryLogs.taggings = ActiveRecord::QueryLogs.taggings.merge({owner: -> { Ownership.owner }})
      end
    end

    require_relative "ownership/marginalia" if defined?(Marginalia)
  end

  ActiveSupport.on_load(:active_job) do
    require_relative "ownership/job_methods"
    include Ownership::JobMethods
  end
else
  require_relative "ownership/marginalia" if defined?(Marginalia)
end

class Exception
  attr_accessor :owner
end
