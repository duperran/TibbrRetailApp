class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :image
      t.string :thumb
      t.string :big
      t.string :title
      t.string :description
      t.string :link

      t.timestamps
    end
  end
end
