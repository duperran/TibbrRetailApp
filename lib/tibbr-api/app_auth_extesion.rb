module Tibbr::AppAuthExtesion
  def current_session_user
    cookies.signed[:access_token] = params[:access_token] || cookies.signed[:access_token] 
    Tibbr::User.access_token= cookies.signed[:access_token] || params[:access_token]
    cookies.signed[:client_id] = params[:client_id] || cookies.signed[:client_id]
    @current_session_user ||= Tibbr::User.find_by_access_token
  end
end