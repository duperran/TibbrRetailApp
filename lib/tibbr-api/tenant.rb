module Tibbr


  class Tenant  < TibbrResource

    def self.create_by_domain(sub_domain, tenant_owner_email)
      new(get(:acquire, :sub_domain => "#{sub_domain}", :tenant_owner_email => "#{tenant_owner_email}"))
    end

    #Always returns a dummy Tenant object
    #the object will have obj.errors.empty? if there are no errors
    #the object will have obj.url which will contain the activation url when in app_config(:multi_tenant, :test_mode) mode
    def self.sign_up(email, referrer_partner, resend_activation_email=false, invitation_text="")
      new.tap {|obj| obj.load_from_response(post(:sign_up, :params => {:email => email, :referrer => referrer_partner, :resend_activation_email=> resend_activation_email, :invitation_text => invitation_text}))}
    rescue ActiveResource::ResourceInvalid => error
      new.tap{|h| h.populate_error(error); h.error_type = :unprocessable_entity}
    rescue ActiveResource::ResourceConflict => error
      new.tap{|h| h.populate_error(error); h.error_type = :conflict}
    end

    def self.sign_ups_history
      response = get(:sign_ups_history)
      hash2object(response["sign_ups_history"])
    end

    def self.activate_url
      "#{Tibbr::TenantUtils.remove_last_slash(site.to_s)}/tenants/activate.#{format.extension}"
    end


    def self.activate options
      user= Tibbr::User.new(options)
      user.attributes["profile_image"] = options[:profile_image] # NOTE: File object becomes null with new(options) for some reason.
      if user.multipart?
        user.multipart_send(activate_url,:put)
        user
      else
        response = post(:activate, :user => options)
        response_hash = Hash.from_xml(response.body)
        User.new(response_hash["user"])
      end
    rescue ActiveResource::ResourceInvalid, ActiveResource::BadRequest => error
      User.new.tap{|h| h.populate_error(error); h.attributes.merge!(options); h.attributes.merge!(options) }
    end

    def self.search_tenants s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get(:search_tenants, {:set_actions => true, :page=>page, :per_page=>per_page}.merge(s_filters||{})), Tenant)
    end

    def self.contact_sales options={}
      description = options[:description] || ""
      contact_number = options[:contact_number] || ""
      response = post(:contact_sales, :details => {:description=> description, :contact_number => contact_number})
    end

    def self.contact_support options={}
      question = options[:question] || ""
      description = options[:description] || ""
      response = post(:contact_support, :enquiry => {:question=> question, :description => description})
    end

    def preferences(options={})
      page = options[:page] || 1
      per_page = options[:per_page] || 999
      group = options[:group_key] || ''
      name = options[:key] || ''
      TibbrResource.paginate_collection(get(:preferences, :params => {:group_key => group, :name => name, :page=> page, :per_page=>per_page}),Preference)
    end

    def create_preference(options={})
      group_key = options[:group_key]
      key = options[:key]
      value = options[:value]
      post(:create_preference, :tenant_preference => {:group_key => group_key, :name => key, :value => value})
    end

    def update_preference(options={})
      group_key = options[:group_key]
      key = options[:key]
      value = options[:value]
      put(:update_preference, :tenant_preference => {:group_key => group_key, :name => key, :value => value})
    end

    def self.all_statistics
      get(:all_statistics,:params=>{:include_owner=>true,:include_object=>true})
    end

  end
end