module DashboardHelper
  def daily_profit
    @daily_profit ||= begin
      row = Statement.today.task_related.totals.take
      (row&.total_credit || 0).abs + (row&.total_debit || 0)
    end
  end

  def credited_accounts
    @credited_accounts ||= begin
      grouped_data = Statement.today.select('account_public_id, SUM(credit) as total_credit, SUM(debit) as total_debit')
        .today.task_related.group(:account_public_id)

      grouped_data.count { (_1.total_credit + _1.total_debit).negative? }
    end
  end

  def top_tasks
    @top_tasks = begin
      Statement.task_related.where("debit > 0").preload(:task)
        .group_by(&:execution_date)
        .transform_values { _1.max_by(&:debit) }
    end
  end
end
