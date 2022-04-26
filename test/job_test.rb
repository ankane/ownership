require_relative "test_helper"

class JobTest < Minitest::Test
  def test_job
    TestJob.perform_now
    assert_equal :logistics, $current_owner
  end
end
