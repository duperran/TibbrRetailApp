module Tibbr
  class Rss

    def self.authenticate_rss_feed url, user=nil, password=nil
      if (user.nil? and password.nil?)
        request = HTTPI::Request.new(url)
        response = HTTPI.get request
        return response.raw_body if response.code = 200
      else
        request = HTTPI::Request.new(url)
        response = HTTPI.get request
        auth_type = response.headers['www-authenticate']
        auth_type = get_auth_type (auth_type)
        response = get_rss_feed auth_type,url, user, password
        return response
      end

      raise cannot_connect_to_rss_feed_error_message
    end


    def self.cannot_connect_to_rss_feed_error_message
      "Not able to connect to the provided rss url tried NTLM,Digest and Basic authentication types"
    end

    def self.get_auth_type auty_type

      return :basic if auty_type =~ /BASIC/i
      return :ntlm if auty_type =~ /NTLM/i
      return :digest if auty_type =~ /DIGEST/i
    end

    def self.get_rss_feed auth_type, url, user, password

      case auth_type
        when :basic
          request = HTTPI::Request.new(url)
          request.auth.basic(user, password)
          response = HTTPI.get request
          return response.raw_body if response.code = 200
        when :ntlm
          request = HTTPI::Request.new(url)
          request.auth.ntlm(user, password)
          response = HTTPI.get request
          return response.raw_body if response.code = 200
        when :digest
          request = HTTPI::Request.new(url)
          request.auth.digest(user, password)
          response = HTTPI.get request
          return response.raw_body if response.code = 200
        else
          logger.error "Invalid auth_type name : #{auth_type}"
      end
    end

  end
end
  