class CreateVanillaPageItems < ActiveRecord::Migration[5.2]
  def change
    create_table :vanilla_page_items do |t|
      t.string :r_id
      t.string :r_name
      t.string :item_page_link
      t.text :item_html_code, :limit => 4294967295
      t.string :image
      t.string :price
      t.string :slogan
      t.string :location
      t.string :latitude
      t.string :longitude
      t.string :contact
      t.string :timing
      t.string :total_reviews
      t.string :cuisine
      t.string :details
      t.string :facebook_link
      t.string :website_link

      t.timestamps
    end
  end
end
