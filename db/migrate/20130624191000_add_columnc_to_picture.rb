class AddColumncToPicture < ActiveRecord::Migration
  def change
    add_column :pictures, :item_id, :string
  end
end
