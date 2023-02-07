class CreatePageItems < ActiveRecord::Migration[5.2]
  def change
    create_table :page_items do |t|
      t.string :r_name
      t.string :p_link
      t.string :website_link
      t.string :location
      t.string :latitude
      t.string :longitude
      t.string :contact
      t.string :total_reviews
      t.string :timing
      t.string :cuisine
      t.string :details

      t.timestamps
    end
  end
end
