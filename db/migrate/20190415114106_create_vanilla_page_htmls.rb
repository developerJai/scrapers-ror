class CreateVanillaPageHtmls < ActiveRecord::Migration[5.2]
  def change
    create_table :vanilla_page_htmls do |t|
      t.string :page_url
      t.text :html_code, :limit => 4294967295

      t.timestamps
    end
  end
end
