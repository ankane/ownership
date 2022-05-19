require_relative "test_helper"

class OwnershipTest < Minitest::Test
  def test_around
    owner :logistics do
      $around_calls << "middle"
    end
    assert_equal ["start", "middle", "finish"], $around_calls
  end

  def test_exception
    error = assert_raises do
      owner :logistics do
        raise "boom"
      end
    end
    assert_equal :logistics, error.owner
  end

  def test_nested_exception
    error = assert_raises do
      owner :logistics do
        owner :sales do
          raise "boom"
        end
      end
    end
    assert_equal :sales, error.owner
  end

  def test_default_owner
    assert_nil Ownership.owner
    Ownership.default_owner = :logistics
    assert_equal :logistics, Ownership.owner
  ensure
    Ownership.default_owner = nil
  end

  def test_respond_to?
    refute nil.respond_to?(:owner)
  end

  def test_method_owner
    assert_equal Kernel, method(:puts).owner
  end

  def test_pry
    assert_equal Kernel, Pry::Method.new(method(:puts)).wrapped_owner.wrapped
  end
end
