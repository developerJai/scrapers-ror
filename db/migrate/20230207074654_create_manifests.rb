class CreateManifests < ActiveRecord::Migration[5.2]
  def change
    create_table :manifests do |t|
      t.integer :lots
      t.float :total_est_value
      t.references :auction, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
