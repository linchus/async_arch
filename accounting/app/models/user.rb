class User < ApplicationRecord
  has_many :auth_providers
  has_many :accounts

  def self.close_day(date = Date.yesterday)
    User.find_each do |user|
      user.accounts.each do |account|
        next if account.statements.for_date(date).where(ref: user, description: "Payout for #{date}").exists?

        day_result = account.statements.task_related.for_date(date).totals.take
        day_balance = (day_result.total_credit || 0) + (day_result.total_debit || 0)
        if day_balance.positive?
          account.statements.create!(
            credit: day_balance,
            description: "Payout for #{date}",
            ref: user,
            created_at: date.end_of_day
          )
          # Send mail
        end
      end
    end
  end
end
