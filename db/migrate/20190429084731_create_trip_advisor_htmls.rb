class CreateTripAdvisorHtmls < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_advisor_htmls do |t|
      t.string :page_url
      t.text :page_html, :limit => 4294967295
      t.references :trip_advisor_main_page_html, foreign_key: true

      t.timestamps
    end
  end
end
