class AddTibbrIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :tibbr_id, :string
  end
end
