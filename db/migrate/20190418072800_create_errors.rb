class CreateErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :errors do |t|
      t.string :error
      t.string :message
      t.string :url

      t.timestamps
    end
  end
end
