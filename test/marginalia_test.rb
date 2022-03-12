require_relative "test_helper"

class MarginaliaTest < Minitest::Test
  # no great way to test SQL comment unfortunately
  # ActiveSupport::Notifications are sent before the comment is added
  def test_marginalia
    assert_includes Marginalia::Comment.components, :owner
  end
end
