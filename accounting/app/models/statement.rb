class Statement < ApplicationRecord
  belongs_to :account
  belongs_to :ref, polymorphic: true
end
