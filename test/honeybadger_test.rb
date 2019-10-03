require_relative "test_helper"

require "honeybadger/ruby"
Honeybadger.init!(framework: :ruby, env: "test", :"logging.path" => Tempfile.new.path)

Honeybadger.configure do |config|
  config.api_key = "default-key"
  config.backend = "test"
  config.logger = Logger.new(IO::NULL)
end

Ownership::Honeybadger.api_keys = {
  logistics: "logistics-key",
  sales: "sales-key",
  support: "support-key"
}

class HoneybadgerTest < Minitest::Test
  def setup
    $around_calls = []

    Honeybadger.config.backend.notifications.clear
    Honeybadger.context.clear!
  end

  def test_tagging
    Honeybadger.context tags: 'critical, badgers'

    owner :logistics do
      Honeybadger.notify("boom for logistics", sync: true)
    end

    assert_equal %w[critical badgers logistics], notices.last.tags

    Honeybadger.context.clear!

    owner :sales do
      Honeybadger.notify("boom for sales", sync: true)
    end

    assert_equal %w[sales], notices.last.tags
  end

  def test_uses_default_key_without_ownership_block
    Honeybadger.notify("boom for default", sync: true)

    assert_equal "default-key", notices.last.api_key
  end

  def test_uses_owner_key_within_ownership_block
    owner :logistics do
      Honeybadger.notify("boom for logistics", sync: true)
    end

    assert_equal "logistics-key", notices.last.api_key
  end

  def test_uses_default_key_and_warns_with_unknown_owner
    assert_output(nil, /Missing Honeybadger API key for owner: unknown/) do
      owner :unknown do
        Honeybadger.notify("boom for default", sync: true)
      end
    end

    assert_equal "default-key", notices.last.api_key
  end

  def test_async_works_properly
    owner :logistics do
      Honeybadger.notify("boom for logistics")
      Honeybadger.flush
    end

    assert_equal "logistics-key", notices.last.api_key
  end

  def test_prefer_exception_owner_over_thread_local_ownership
    owner :logistics do
      ex = StandardError.new("boom for sales")
      ex.owner = :sales

      Honeybadger.notify(ex, sync: true)
    end

    assert_equal "sales-key", notices.last.api_key
  end

  private

  def notices
    Honeybadger.config.backend.notifications[:notices]
  end
end
