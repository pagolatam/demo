class Product < ApplicationRecord
  has_many :line_items
  validates :name, :description, :price, presence: true
end
