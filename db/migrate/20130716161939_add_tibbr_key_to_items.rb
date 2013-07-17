class AddTibbrKeyToItems < ActiveRecord::Migration
  def change
    add_column :items, :tibbr_key, :string
  end
end
