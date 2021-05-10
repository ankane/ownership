module Ownership
  module GlobalMethods
    private

    def owner(*args, &block)
      return super if is_a?(Method) # hack for pry

      owner = args.first
      kwargs =
        case args.last
        when Hash then args.pop
        else {}
        end

      methods = kwargs.fetch(:methods, :__not_set__)
      # same error message as Ruby
      raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 1)" if args.size != 1

      if block_given?
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
      elsif methods == :__not_set__
        raise ArgumentError, "Missing block"
      else
        self.include Ownership::Owner.for(*methods, owner: owner)
      end
    end
  end
end
