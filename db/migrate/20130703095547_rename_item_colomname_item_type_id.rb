class RenameItemColomnameItemTypeId < ActiveRecord::Migration
  def self.up
    rename_column :items, :itemTypeId, :item_type_id
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
