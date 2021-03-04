class Order < ApplicationRecord
  include UniversallyUniqueIdentifiable

  has_many :payments
  has_many :line_items
  has_many :products, through: :line_items

  validates :token, :amount, :customer_email, presence: true
  enum status: { pending: 0, confirmed: 1 }
  before_validation :set_amount
  before_create :set_pending

  private

  def set_pending
    self.status = 0
  end

  def set_amount
    self.amount = 0
    line_items.each do |line_item|
      self.amount += line_item.price * line_item.quantity
    end
  end
end