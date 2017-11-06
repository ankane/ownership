require "active_support/concern"

module Ownership
  module JobMethods
    extend ActiveSupport::Concern

    class_methods do
      def owner(*args)
        around_perform do |_, block|
          owner(*args) { block.call }
        end
      end
    end
  end
end
