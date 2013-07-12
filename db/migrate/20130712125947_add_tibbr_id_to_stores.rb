class AddTibbrIdToStores < ActiveRecord::Migration
  def change
    add_column :stores, :tibbr_id, :string
  end
end
