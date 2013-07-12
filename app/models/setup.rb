class Setup < ActiveRecord::Base
  attr_accessible :access_token, :app_id, :client_secret, :server_url, :system_admin_id, :tenant_name
  
  
  
  def decrypt_key
    "947aafe0-e8b1-11e2-9fa4-a4199b3"
  end
  
  
end
