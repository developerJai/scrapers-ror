class CreateAuctionSites < ActiveRecord::Migration[5.2]
  def change
    create_table :auction_sites do |t|
      t.string :website
      t.string :site_name
      t.string :site_url
      t.string :short_description
      t.text :full_description
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :shipping_available
      t.string :ship_from
      t.float :premium
      t.datetime :last_scanned
      t.string :site_type
      t.string :category
      t.string :unparsed_address
      t.string :address
      t.string :country
      t.string :latitude
      t.string :longitude
      t.text :policies
      t.string :auction_store_id

      t.timestamps
    end
  end
end
