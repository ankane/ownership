class HomeController < ActionController::Base
  owner :logistics

  def index
    $current_owner = Ownership.owner
    head :ok
  end
end
