require_relative "test_helper"

require "rollbar"

Rollbar.configure do |config|
  config.logger = Logger.new(nil)
  config.access_token = "footoken"
  config.transmit = false
  config.disable_monkey_patch = true
  config.use_payload_access_token = true
end

Ownership::Rollbar.access_token = {
  logistics: "logistics-token",
  sales: "sales-token",
  support: "support-token"
}

Rollbar.configure do |config|
  config.transform << proc do |options|
    $errors << options
  end
end

class RollbarTest < Minitest::Test
  def setup
    super
    $errors = []
  end

  def test_error
    begin
      owner :logistics do
        raise "Error"
      end
    rescue => e
      Rollbar.error(e)
    end

    assert_equal 1, $errors.size
    assert_equal "logistics-token", $errors.last[:payload]["access_token"]
  end
end
