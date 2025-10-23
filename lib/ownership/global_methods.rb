module Ownership
  module GlobalMethods
    private

    def owner(owner, &block)
      raise ArgumentError, "Missing block" unless block_given?

      previous_value = Thread.current[:ownership_owner]
      begin
        Thread.current[:ownership_owner] = owner

        # callbacks
        if Ownership.around_change
          Ownership.around_change.call(owner, block)
        else
          block.call
        end
      rescue Exception => e
        e.owner ||= owner
        raise
      ensure
        Thread.current[:ownership_owner] = previous_value
      end
    end
  end
end
