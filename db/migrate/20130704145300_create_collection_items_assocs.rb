class CreateCollectionItemsAssocs < ActiveRecord::Migration
  def change
    create_table :collection_items_assocs do |t|
      t.string :item_id
      t.string :collection_id

      t.timestamps
    end
  end
end
