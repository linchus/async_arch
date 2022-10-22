class AccountsController < ApplicationController
  before_action :require_user_logged_in!

  def index
    @accounts = current_user.accounts.order(:id)
  end

  def show
    @account = current_user.accounts.find(params[:id])
    @statements = @account.statements.preload(:ref).order(id: :desc)
  end
end
