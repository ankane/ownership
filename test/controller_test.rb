require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def test_controller
    get root_url
    assert_equal :logistics, $current_owner
  end
end
