module Tibbr

  class TenantUtils
    # === public class methods
    # NOTE: we accept username@domain format. Do not change it to username@domain.code format.

    def self.domain_list
      @@domain =["arts", "firm", "info", "nom", "rec", "store", "web", "aero", "asia", "biz", "cat", "com", "coop", "info", "int", "jobs", "mobi", "museum", "name", "net", "org", "pro", "tel", "travel", "xxx", "edu", "gov", "mil", "ac", "ad", "ae", "af", "ag", "ai", "al", "am", "an", "ao", "aq", "ar", "as", "at", "au", "aw", "ax", "az", "ba", "bb", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bm", "bn", "bo", "br", "bs", "bz", "bv", "bw", "by", "bz", "ca", "cc", "cd", "cf", "cg", "ch", "ci", "ck", "cl", "cm", "cn", "co", "cr", "cs", "cu", "cv", "cx", "cy", "cz", "dd", "de", "dj", "dk", "dm", "do", "dz", "ec", "ee", "eg", "eh", "er", "es", "et", "eu", "fi", "fj", "fk", "fm", "fo", "fr", "ga", "gb", "gd", "ge", "gf", "gg", "gh", "gi", "gl", "gm", "gn", "gp", "gq", "gr", "gs", "gt", "gu", "gw", "gy", "hk", "hm", "hn", "hr", "ht", "hu", "id", "ie", "il", "im", "in", "io", "iq", "ir", "is", "it", "je", "jm", "jo", "jp", "ke", "kg", "kh", "ki", "km", "kn", "kp", "kr", "kw", "ky", "kz", "la", "lb", "lc", "li", "lk", "lr", "ls", "lt", "lu", "lv", "ly", "ma", "mc", "md", "me", "mg", "mh", "mk", "ml", "mm", "mn", "mo", "mp", "mq", "mr", "ms", "mt", "mu", "mv", "mw", "mx", "my", "mz", "na", "nc", "ne", "nf", "ng", "ni", "nl", "no", "np", "nr", "nu", "nz", "om", "pa", "pe", "pf", "pg", "ph", "pk", "pl", "pm", "pn", "pr", "ps", "pt", "pw", "py", "qa", "re", "ro", "rs", "ru", "rw", "sa", "sb", "sc", "sd", "se", "sg", "sh", "si", "sj", "sk", "sl", "sm", "sn", "so", "sr", "ss", "st", "su", "sv", "sy", "sz", "tc", "td", "tf", "tg", "th", "tj", "tk", "tl", "tm", "tn", "to", "tp", "tr", "tt", "tv", "tw", "tz", "ua", "ug", "uk", "us", "uy", "uz", "va", "vc", "ve", "vg", "vi", "vn", "vu", "wf", "ws", "ye", "yt", "yu", "za", "zm", "zw"]
    end

    def self.is_valid_domain? email_domain
      validate_domain(email_domain)
      return true
    rescue Exception => error
      Rails.logger.error "is_valid_domain? #{error.message}"
      return false
    end

    def self.validate_domain email_domain
      count = 1
      raise invalid_domain_error_message unless self.domain_list.include? email_domain.split('.').last
      email_domain.split('.').reverse.each do |s|
        if self.domain_list.include? s
          raise invalid_domain_error_message if count >3
          count += 1
        end
      end
      return true
    end


    def self.get_subdomain_from_name domain
      raise invalid_domain_error_message unless self.domain_list.include? domain.split('_').last
      subdomain_str = []
      count = 1
      domain.split('_').reverse.each do |s|
        subdomain_str << s if !self.domain_list.include? s || count >3
        count += 1
      end
      subdomain_str.reverse.join('_')
    end

    def self.is_valid_email? email
      e_domain = email_domain(email)
      return is_valid_domain? e_domain
    rescue Exception => error
      Rails.logger.error "is_valid_email? #{error.message}"
      return false
    end


      def self.email_domain email
        m = /(.+?)[@](.*\.)?([a-zA-Z0-9_-]+\.(com|net|org))$|(.+?)[@](.+)/.match email.downcase
        raise invalid_email_error_message unless m
        return m[3]||m[6]
      end

    def self.tenant_domain email
      check_tenant_name(email)
    end

    def self.qualified_domain email
      "https://#{tenant_domain(email)}.tibbr.com"
    end

    def self.invalid_email_error_message
      "Invalid email. Email is not in the <id>@<company>.<domain_qualifier> format. For example myid@tibco.com"
    end

    def self.invalid_domain_error_message
      "Invalid email.The email provided is not valid one"
    end

    def self.user_login_name email
      m= /(.+?)[@](.+)/.match email.downcase
      raise invalid_email_error_message unless m
      m[1]
    end

    def self.remove_last_slash url
      ((url) =~/\/$/).nil? ? url : url.chop
    end

    private
    def self.check_tenant_name email
      probable_tenant=""
      email_domain_string = email_domain(email)
      return email_domain_string if email_domain_string=='tibbr'
      name = Mt::TenantDomain.find_by_name(email_domain_string).try(:tenant_name)
      return name unless name.nil?
      email_domain_string.split('.').reverse.each do |s|
        if self.domain_list.include? s
          probable_tenant.insert(0, s).insert(0, '_')
        else
          probable_tenant.insert(0, s)
          break
        end
      end
      probable_tenant.gsub /[^a-z0-9]/, '_'
    end

  end
end

