class AddPageIdToVanillaPageItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :vanilla_page_items, :vanilla_page_html, foreign_key: true
  end
end
