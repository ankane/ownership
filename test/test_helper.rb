require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

logger = ActiveSupport::Logger.new(ENV["VERBOSE"] ? STDOUT : nil)

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_controller, :active_job do
  config.load_defaults Rails::VERSION::STRING.to_f

  config.action_controller.logger = logger
  config.active_record.logger = logger
  config.active_job.logger = logger
  config.active_record.query_log_tags_enabled = true

  require "marginalia"
end

class Minitest::Test
  def setup
    $current_owner = nil
    $around_calls = []
  end
end

Ownership.around_change = proc do |owner, block|
  $around_calls << "start"
  block.call
  $around_calls << "finish"
end
