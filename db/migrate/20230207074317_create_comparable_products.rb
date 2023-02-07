class CreateComparableProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :comparable_products do |t|
      t.references :product, foreign_key: true
      t.string :name
      t.string :image_link
      t.string :store_type
      t.float :price
      t.string :currency
      t.string :store_link
      t.float :shipping_weight
      t.integer :qty_available
      t.float :shipping_cost
      t.string :shipping_unit
      t.string :item_location
      t.string :ships_to
      t.string :returns
      t.string :condition
      t.string :category
      t.string :sub_categories
      t.float :ebay_fee_amount
      t.float :ebay_fee_percantage
      t.float :ebay_gross_revenue

      t.timestamps
    end
  end
end
