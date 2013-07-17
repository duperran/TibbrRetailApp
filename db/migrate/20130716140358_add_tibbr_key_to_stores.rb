class AddTibbrKeyToStores < ActiveRecord::Migration
  def change
    add_column :stores, :tibbr_key, :string
  end
end
