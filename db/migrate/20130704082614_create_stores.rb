class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.string :street_number
      t.string :street
      t.string :zipcode
      t.string :city
      t.string :country
      t.string :longitude
      t.string :latitude
      t.string :manager

      t.timestamps
    end
  end
end
