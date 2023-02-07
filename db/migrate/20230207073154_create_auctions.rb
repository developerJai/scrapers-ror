class CreateAuctions < ActiveRecord::Migration[5.2]
  def change
    create_table :auctions do |t|
      t.string :main_site
      t.string :auction_url
      t.datetime :opening_date
      t.datetime :closing_date
      t.datetime :bidding_open
      t.string :short_description
      t.text :full_description
      t.integer :lots
      t.string :shipping_type
      t.float :premium
      t.integer :pallet_count
      t.string :auction_store_id
      t.references :user, foreign_key: true
      t.string :site
      t.integer :ebay_value
      t.integer :amz_value
      t.integer :negg_value
      t.float :shipping_cost
      t.boolean :shipping_offered
      t.references :auction_site, foreign_key: true
      t.boolean :ended
      t.boolean :online_only
      t.boolean :scanned
      t.string :title
      t.text :unparsed_address
      t.string :latitude
      t.string :longitude
      t.float :distance
      t.string :auctioneer_name
      t.string :auction_url_code
      t.string :event_name
      t.string :auction_city
      t.string :auction_zip
      t.string :featured_picture_full
      t.string :featured_picture_thumb
      t.string :featured_picture_description
      t.boolean :hide
      t.string :bidding_notice
      t.string :auction_notice
      t.string :time_zone

      t.timestamps
    end
  end
end
