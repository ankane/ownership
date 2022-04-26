class UsersController < ActionController::Base
  owner :logistics, only: [:index]
  owner :customers, except: [:index]

  def index
    $current_owner = Ownership.owner
    head :ok
  end

  def show
    $current_owner = Ownership.owner
    head :ok
  end
end
