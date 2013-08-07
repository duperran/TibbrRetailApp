class ApplicationController < ActionController::Base
 
  protect_from_forgery
  include Tibbr::AppAuthExtesion
  
  before_filter :set_session
  def home
    
    
  end
  
  
  def is_setup?
    
    if Setup.find_by_app_id(session[:app_id]).nil?
      redirect_to "/not_setup.html"
    end
  end

  def setup
    @setup if @setup.present?
    @setup = Setup.find_by_app_id(session[:app_id])
    @setup
  end

  def set_session

    pp "SSSSSSS"
    if  (session[:access_token] != params[:access_token]) && !params[:access_token].nil?
      # must be a new user logge din...
      session.except!([:app_id, :user_id, :access_token, :tibbr_server_url, :ssl])
    end

    session[:app_id] = params[:client_key] if params[:client_key]
   
    if (current_user)
    
    session[:user_id] = current_user.id
    else
      render "public/open_retail_app.html"
    end
    session[:access_token] = params[:access_token] if params[:access_token]
    session[:tibbr_server_url]  = params[:tibbr_server_url] if params[:tibbr_server_url]
    session[:ssl]  = params[:ssl]  if params[:ssl]
  end

  def current_user
    @current_user if @current_user.present?
    Tibbr::User.access_token = !session[:access_token].nil? ? session[:access_token] : params[:access_token]
    #Tibbr::User.access_token = params[:access_token]
    @current_user = Tibbr::User.find_by_access_token
  
    @current_user
  end

  def app_owner_access_token
    access_token = nil
    app_def = Tibbr::ApplicationDefinition.find(session[:app_id])
    if !app_def.nil?
      user = Tibbr::User.get_access_token(app_def.user_id, {:client_secret=>setup.client_secret, :client_id=>setup.app_id})
      access_token = user.access_token if !user.nil?
    end
    access_token
  end

  def application_config_decrypt_key
    setup.decrypt_key
  end
  
 
end
