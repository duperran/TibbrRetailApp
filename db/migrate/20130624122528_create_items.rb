class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :reference
      t.string :name

      t.timestamps
    end
  end
end
