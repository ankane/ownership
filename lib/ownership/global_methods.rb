module Ownership
  module GlobalMethods
    private

    def owner(owner = nil, &block)
      return super() if is_a?(Method) # hack for pry

      raise ArgumentError, "Missing owner" unless owner
      raise ArgumentError, "Missing block" unless block_given?

      previous_value = Thread.current[:ownership_owner]
      begin
        Thread.current[:ownership_owner] = owner

        begin
          # callbacks
          if Ownership.around_change
            Ownership.around_change.call(owner, block)
          else
            block.call
          end
        rescue Exception => e
          e.owner = owner
          raise
        end
      ensure
        Thread.current[:ownership_owner] = previous_value
      end
    end
  end
end
