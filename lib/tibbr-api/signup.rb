module Tibbr
  class SignUp  < TibbrResource
    def self.find_signup_by_activation options={}
      get(:find_signup_by_activation, :sign_up => {:activation_code=> options[:activation_code], :email => options[:email]}) rescue nil
    end
  end
end