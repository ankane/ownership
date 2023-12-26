require_relative "test_helper"

$io = StringIO.new
ActiveRecord::Base.logger = ActiveSupport::Logger.new($io)

class ActiveRecordTest < Minitest::Test
  def setup
    skip if ActiveRecord::VERSION::MAJOR < 7

    ActiveRecord::QueryLogs.tags = [:owner]
    super
    $io.truncate(0)
  end

  def teardown
    ActiveRecord::QueryLogs.tags = []
  end

  def test_owner
    owner(:logistics) do
      User.last
    end
    if ActiveRecord::VERSION::STRING.to_f >= 7.1
      assert_match "/*owner='logistics'*/", logs
    else
      assert_match "/*owner:logistics*/", logs
    end
  end

  def test_no_owner
    User.last
    refute_match "owner", logs
  end

  def logs
    $io.rewind
    $io.read
  end
end
