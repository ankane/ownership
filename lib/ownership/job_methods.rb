require "active_support/concern"

module Ownership
  module JobMethods
    extend ActiveSupport::Concern

    class_methods do
      def owner(owner)
        around_perform do |_, block|
          owner(owner) { block.call }
        end
      end
    end
  end
end
