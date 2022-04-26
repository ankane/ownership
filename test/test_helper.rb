require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

logger = ActiveSupport::Logger.new(ENV["VERBOSE"] ? STDOUT : nil)

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_controller, :active_job do
  if ActiveRecord::VERSION::MAJOR < 6 && config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

  config.action_controller.logger = logger
  config.active_record.logger = logger
  config.active_job.logger = logger

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
