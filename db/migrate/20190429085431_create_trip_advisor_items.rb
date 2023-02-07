class CreateTripAdvisorItems < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_advisor_items do |t|
      t.string :item_page_url
      t.text :item_page_html, :limit => 4294967295
      t.references :trip_advisor_html, foreign_key: true
      t.string :r_id
      t.string :r_name
      t.string :location
      t.string :latitude
      t.string :longitude
      t.string :contact
      t.string :email
      t.string :price
      t.string :timing
      t.string :cuisine
      t.string :meals
      t.string :special_diet
      t.string :features
      t.string :details
      t.string :total_reviews
      t.string :total_rating
      t.string :website_link
      t.string :image

      t.timestamps
    end
  end
end
