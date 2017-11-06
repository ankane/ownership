require "bundler/setup"
require "active_job"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record" # for marginalia
require "marginalia"

ActiveJob::Base.logger.level = :warn

class TestJob < ActiveJob::Base
  owner :logistics

  def perform
    $current_owner = Ownership.owner
  end
end

class User < ActiveRecord::Base
end

Ownership.around_change = proc do |owner, block|
  $around_calls << "start"
  block.call
  $around_calls << "finish"
end
