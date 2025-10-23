require "active_support/concern"

module Ownership
  module ControllerMethods
    extend ActiveSupport::Concern

    class_methods do
      def owner(owner, **options)
        around_action(**options) do |_, block|
          owner(owner) { block.call }
        end
      end
    end
  end
end
