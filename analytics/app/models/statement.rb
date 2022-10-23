class Statement < ApplicationRecord
  belongs_to :task, foreign_key: :ref_public_id, primary_key: :public_id

  scope :totals, -> { select('SUM(credit) as total_credit, SUM(debit) as total_debit') }
  scope :today, -> { where('DATE(created_at) = CURRENT_DATE') }
  scope :for_date, ->(date) { where("DATE(created_at) = ?", date) }
  scope :task_related, -> { where(ref_type: 'Task') }

  def execution_date
    created_at.to_date
  end
end
