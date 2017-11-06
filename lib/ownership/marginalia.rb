module Marginalia
  module Comment
    def self.owner
      Ownership.owner
    end
  end
end

Marginalia::Comment.components << :owner
