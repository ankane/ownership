require_relative "test_helper"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end
end

$io = StringIO.new
ActiveRecord::Base.logger = ActiveSupport::Logger.new($io)

if ActiveRecord::VERSION::MAJOR >= 7
  ActiveRecord.query_transformers << ActiveRecord::QueryLogs
  ActiveRecord::QueryLogs.tags = [:owner]
end

class ActiveRecordTest < Minitest::Test
  def setup
    skip if ActiveRecord::VERSION::MAJOR < 7

    super

    $io.truncate(0)
  end

  def test_owner
    owner(:logistics) do
      User.last
    end
    assert_match "/*owner:logistics*/", logs
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
