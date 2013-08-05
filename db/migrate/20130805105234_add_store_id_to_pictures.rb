class AddStoreIdToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :store_id, :string
  end
end
