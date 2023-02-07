class CreateTripAdvisorMainPageHtmls < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_advisor_main_page_htmls do |t|
      t.string :page_url
      t.text :page_html, :limit => 4294967295

      t.timestamps
    end
  end
end
