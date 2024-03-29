module Ownership
  module GlobalMethods
    private

    def owner(*args, &block)
      return super if is_a?(Method) # hack for pry

      owner = args[0]
      # same error message as Ruby
      raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 1)" if args.size != 1
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
