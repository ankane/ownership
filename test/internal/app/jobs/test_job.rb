class TestJob < ActiveJob::Base
  owner :logistics

  def perform
    $current_owner = Ownership.owner
  end
end
