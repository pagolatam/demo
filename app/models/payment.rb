class Payment < ApplicationRecord
  include UniversallyUniqueIdentifiable

  belongs_to :order

  validates :token, :amount, presence: true
  enum status: %i[pending confirmed failed]
end
