module AccountsHelper
  def today_profit
    @today_profit ||= begin
      row = Statement.today.task_related.totals.take
      (row&.total_credit || 0).abs + row&.total_debit || 0
    end
  end
end
