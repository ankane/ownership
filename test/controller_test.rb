require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def test_controller
    get root_url
    assert_equal :logistics, $current_owner
  end

  def test_only
    get users_url
    assert_equal :logistics, $current_owner
  end

  def test_except
    get user_url(1)
    assert_equal :customers, $current_owner
  end
end
