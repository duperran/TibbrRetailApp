class CreateSetups < ActiveRecord::Migration
  def change
    create_table :setups do |t|
      t.string :app_id
      t.string :client_secret
      t.string :server_url
      t.string :system_admin_id
      t.string :tenant_name
      t.string :access_token

      t.timestamps
    end
  end
end
