require_relative "test_helper"

class OwnershipTest < Minitest::Test
  def setup
    $current_owner = nil
    $around_calls = []
  end

  def test_job
    TestJob.perform_now
    assert_equal :logistics, $current_owner
  end

  # no great way to test SQL comment unfortunately
  # ActiveSupport::Notifications are sent before the comment is added
  def test_marginalia
    assert_includes Marginalia::Comment.components, :owner
  end

  def test_around
    owner :logistics do
      $around_calls << "middle"
    end
    assert_equal $around_calls, ["start", "middle", "finish"]
  end

  def test_exception
    error = assert_raises do
      owner :logistics do
        raise "boom"
      end
    end
    assert_equal error.owner, :logistics
  end

  def test_respond_to?
    assert !nil.respond_to?(:owner)
  end

  def test_method_owner
    assert_equal Kernel, method(:puts).owner
  end

  def test_pry
    assert_equal Kernel, Pry::Method.new(method(:puts)).wrapped_owner.wrapped
  end

  def test_claiming_instance_method
    klass = Class.new do
      owner :logistics, methods: [:call]

      def call
        raise "boom"
      end
    end

    error = assert_raises { klass.new.call }
    assert_equal error.owner, :logistics
  end

  def test_claiming_singleton_method
    klass = Class.new do
      class << self
        owner :sales, methods: [:call]
      end

      def self.call
        raise "boom"
      end
    end

    error = assert_raises { klass.call }
    assert_equal error.owner, :sales
  end
end
