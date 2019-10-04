require_relative "test_helper"

class OwnerTest < Minitest::Test
  def setup
    $around_calls = []
  end

  def test_owner_for_call_method
    klass = Class.new do
      include Ownership::Owner.for :call, owner: :logistics

      def call
        raise "boom"
      end
    end

    assert_equal "Ownership::Owner.for<call>", klass.instance_method(:call).owner.inspect

    begin
      klass.new.call
    rescue => ex
      assert_equal :logistics, ex.owner
    end
  end

  def test_owner_for_class_method
    klass = Class.new do
      extend Ownership::Owner.for :call, owner: :sales

      def self.call
        raise "boom"
      end
    end

    assert_equal "Ownership::Owner.for<call>", klass.method(:call).owner.inspect

    begin
      klass.call
    rescue => ex
      assert_equal :sales, ex.owner
    end
  end
end
