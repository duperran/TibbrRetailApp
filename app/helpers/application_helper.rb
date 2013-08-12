module ApplicationHelper
  
  def config_tibbr_site_root
    
     @config_tibbr_site= APP_CONFIG[Rails.env]['api']['site_root']
  end 
  
  def config_tibbr_host
     @config_tibbr_host= APP_CONFIG[Rails.env]['host']
   end
  
   def client_id
     @client_id = APP_CONFIG[Rails.env]['retail']['client_id']
   end
  
  def title(page_title)
    content_for :title, page_title.to_s
  end

  def retail_app_id
    session[:app_id]
  end

  def tibbr_url
     url = session[:tibbr_server_url]
     return url unless session.has_key?(:ssl)
     if session[:ssl] == "1"
         url.gsub(/^http:\/\//, "https://")
     else
         url.gsub(/^https:\/\//, "http://")
     end
     url = url + "/" unless url.ends_with?("/")
     url
   end

   def tibbr_host
     host = tibbr_url
     host.gsub(/https?:\/\//, "")
   end

   def tibbr_prefix
     current_tenant.config_get("tibbr_prefix")
   end

   def tib_js_url
     url = tibbr_url
     url += "/" unless url.end_with?("/")
     url += "connect/js/TIB.js"
     url
   end

  def retail_app_url
    APP_CONFIG[Rails.env]['retail']['root']
  end

  def setup
     @setup if @setup.present?
     @setup = Setup.find_by_app_id(session[:app_id])
     @setup
  end
end
