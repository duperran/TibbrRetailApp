class AddColumncToItem < ActiveRecord::Migration
  def change
    add_column :items, :itemTypeId, :string
  end
end
