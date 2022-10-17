class Task < ApplicationRecord
  def initialize(*, **)
    super

    self.assign_price ||= rand(10) - 20
    self.resolve_price ||= rand(20) + 20
  end
end
