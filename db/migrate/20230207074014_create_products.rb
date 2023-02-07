class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :category
      t.integer :quantity
      t.text :description
      t.string :upc_code
      t.string :product_weight
      t.string :dimensions
      t.string :condition
      t.string :brand_name
      t.float :retail_price
      t.integer :picture_count
      t.string :packaging
      t.string :manufacturer
      t.string :product_model_name
      t.string :ebay_search
      t.string :amazon_search
      t.string :file_name
      t.string :storage_bin
      t.integer :remaining_quantity
      t.float :shipping_cost
      t.boolean :shipping_offered
      t.float :est_value
      t.float :est_price
      t.float :total_retail_purchased
      t.float :total_retail_remaining
      t.boolean :scanned
      t.string :job_id
      t.string :manifest_id
      t.string :margin
      t.boolean :active
      t.text :sub_category
      t.integer :bid_count
      t.float :bid_max
      t.float :buy_now
      t.float :high_bid
      t.float :min_bid
      t.float :price_realized
      t.integer :quantity_sold
      t.string :time_left
      t.string :product_url
      t.string :item_id
      t.boolean :has_comparables
      t.float :ebay_profit_estimate
      t.float :max_bid_price
      t.float :min_bid_price
      t.datetime :auction_closing_time
      t.float :min_comp_price
      t.float :max_comp_price
      t.float :avg_comp_price
      t.float :profit_potential_price
      t.string :time_zone
      t.string :event_item_id
      t.string :sub_categories

      t.timestamps
    end
  end
end
