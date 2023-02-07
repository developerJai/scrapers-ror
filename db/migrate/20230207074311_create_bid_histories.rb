class CreateBidHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :bid_histories do |t|
      t.references :product, foreign_key: true
      t.string :username
      t.string :bid_count
      t.string :bid_amount
      t.string :bid_date_time

      t.timestamps
    end
  end
end
