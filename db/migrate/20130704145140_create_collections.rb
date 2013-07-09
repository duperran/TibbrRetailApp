class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
      t.string :season
      t.string :year

      t.timestamps
    end
  end
end
