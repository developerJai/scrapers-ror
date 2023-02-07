class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.string :latitude
      t.string :longitude
      t.string :unparsed_address

      t.timestamps
    end
  end
end
