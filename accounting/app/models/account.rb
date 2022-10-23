class Account < ApplicationRecord
  DEFAULT_CURRENCY = 'INR'
  belongs_to :user
  has_many :statements

  def update_balance!
    balance_row = statements.totals.take!
    update!(
      cached_balance: (balance_row.total_credit || 0)  + (balance_row.total_debit || 0)
    )
  end
end
