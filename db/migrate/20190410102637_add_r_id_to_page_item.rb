class AddRIdToPageItem < ActiveRecord::Migration[5.2]
  def change
    add_column :page_items, :r_id, :string
    add_column :page_items, :item_html_code, :text, :limit => 4294967295
    add_column :page_items, :facebook_url, :string
  end
end
