class Order < ApplicationRecord
  include UniversallyUniqueIdentifiable

  has_many :payments
  has_many :line_items
  
  validates :token, :amount, :customer_email, presence: true
  enum status: %i[pending confirmed]
end