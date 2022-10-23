class Statement < ApplicationRecord
  scope :totals, -> { select('SUM(credit) as total_credit, SUM(debit) as total_debit') }
  scope :today, -> { where('DATE(created_at) = CURRENT_DATE') }
  scope :for_date, ->(date) { where("DATE(created_at) = ?", date) }
  scope :task_related, -> { where(ref_type: 'Task') }
end
