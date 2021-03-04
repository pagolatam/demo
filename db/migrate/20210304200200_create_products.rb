class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
      t.decimal :price, precision: 10, scale: 2, null: false
    end

    create_table :line_items do |t|
      t.references :product
      t.references :order
      t.integer :quantity
    end

    create_table :orders do |t|
      t.string :status
      t.string :token
      t.string :customer_email
      t.decimal :amount, precision: 10, scale: 2, null: false
    end

    create_table :payments do |t|
      t.references :order
      t.string :status
      t.string :token
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
