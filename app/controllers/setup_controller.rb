require "encryptor"

class SetupController < ApplicationController

  skip_filter :set_session, :only=> [:index]
  skip_filter :is_setup?, :only=> [:index]

  def index
    p = nil
    begin
      p = config_decode(params['config_key'])
      Tibbr::User.client_id=p["client_id"]
      Tibbr::User.client_secret=p["client_secret"]

      user = Tibbr::User.get_access_token(p["system_admin_id"], {:client_secret=>p["client_secret"], :client_id=>p["client_id"]})
    rescue => e
      Rails.logger.error e.to_s
      Rails.logger.error e.backtrace.join("\n")
    end
    if p
      @setup = Setup.find_or_create_by_app_id(:app_id => p["client_id"])
      p.merge!({:access_token => user.access_token})
      p.each do |k, v|
        next if !@setup.has_attribute? k
        @setup.update_attribute(k, v)
      end
    end
    render :layout => false
  end

  private
  def config_decode code
    encryptor = Encryptor.new("947aafe0-e8b1-11e2-9fa4-a4199b3", "")
    str = encryptor.decrypt(code)
    query_hash = Rack::Utils.parse_nested_query(str)
    query_hash
  end
end