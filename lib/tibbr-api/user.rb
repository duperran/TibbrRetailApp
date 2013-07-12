# require 'rest_client'
require 'uri'
require 'pp'

module Tibbr
  
  class User < TibbrResource

    @@res = nil

    # FIXME: Overwritten method, to bypass sending user payload to server while fetching meta details.
    def meta_details(reload=false)
      return (@metadetails ||= self.class.meta_details) unless reload
      @metadetails = self.class.meta_details
    end

    # Deprecating custom properties, using dyna_fields we can use custom properties as user object methods/properties directly.
#    def initialize(object_hash)
      #object_hash.delete("custom_properties") if object_hash.keys.include?("custom_properties")
      #@badges = (object_hash.delete("badges")||{}).symbolize_keys if object_hash.keys.include?("badges")
 #     super
  #  end

    # Update the resource on the remote service.
    def update
      key = self.cache_key
      multipart? ? multipart_send(update_url,:put) : super
      return false unless errors.empty?
      User.cache_remove(key) # remove the old key
      return true
    end
  
    # Create (i.e., \save to the remote service) the \new resource.
    def create
      (multipart? ? multipart_send(create_url,:post) : super).instance_of?(Net::HTTPCreated)
    end

    def delete
      load_from_response(put(:delete))
    end

    def undelete
      load_from_response(put(:undelete))
    end

    def activate_user
      put(:activate_user).instance_of?(Net::HTTPOK)
    end

    def logout
      put(:logout)
    end

    def impersonate(options={}, &block)
      return false if options.blank?
      # Identify if there is a valid impersonate param and pass it as a header
      opts = options.dup.with_indifferent_access
      impersonate_param_key = ['impersonate_user_id', 'impersonate_user_login', 'impersonate_user_email', 'impersonate_user_channel_email',
        'user_id', 'user_login', 'user_email', 'user_channel_email'].select do |allowed_param|
        (opts.has_key?(allowed_param) and opts[allowed_param].present?)
      end.first
      return false if impersonate_param_key.blank? or opts[impersonate_param_key].blank?
      old_impersonate_param = Tibbr::TibbrResource.impersonate_param
      u = User.new(get(:impersonate, :params => options)) # This is required because we need to maintain the impersonated user's id in the request URL due to a different bug
      Tibbr::TibbrResource.impersonate_param = [impersonate_param_key,opts[impersonate_param_key]]
      block.call(u)
      return true
    ensure
      Tibbr::TibbrResource.impersonate_param = old_impersonate_param
    end

    def set_last_read_message_id(message_id)
      put(:set_last_read_message, :params =>{:message_id => message_id}).instance_of?(Net::HTTPOK)
    end

    def message_filters *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      user_id ||= self.id
      cache_lookup(user_id, "message_filters", page, per_page) ||
        TibbrResource.paginate_collection(get(:message_filters, :params => {:user_id => user_id, :page=>page, :per_page=>per_page}), MessageFilter)
    end

    def communities *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      user_id ||= self.id
      inst_cache_lookup('@communities', true, page, per_page) do
        cache_lookup(user_id, "communities", page, per_page) ||
          TibbrResource.paginate_collection(get(:communities, :params => {:user_id => user_id, :page=>page, :per_page=>per_page}), Community)
      end
    end

    def application_message_filters *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      user_id ||= self.id
      TibbrResource.paginate_collection(get(:subscribed_applications_filters, :params => {:user_id => user_id, :page=>page, :per_page=>999}), ApplicationDefinition)
    end

    def all_subscribed_applications *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      user_id ||= self.id
      TibbrResource.paginate_collection(get(:all_subscribed_applications, :params => {:user_id => user_id, :page=>page, :per_page=>999}), ApplicationDefinition)
    end


    def children_fetched?
      attributes.has_key?('children')
    end

    #Returns: Array of User (immediate children of this user)
    def children options={}
      attributes['children'] || TibbrResource.simple_collection(get(:children, :params => options.reverse_merge({:set_actions => true})), User)
    end

    #Returns: User (parent of this user)
    def parent options={}
      User.new(get(:parent, :params => options.reverse_merge({:set_actions => true})))
    end

    #Returns: User (root user in the tree along with hierarchy upto this user + one level down)
    def ancestry_tree options={}
      user_hash = get(:ancestry_tree, :params => options.reverse_merge({:set_actions => true}))
      User.user_with_hierarchy(user_hash)
    end

    #Returns: User (this user along with hierarchy)
    def subtree options={}
      user_hash = get(:subtree, :params => options.reverse_merge({:set_actions => true}))
      User.user_with_hierarchy(user_hash)
    end

    #Returns: root user in the tree along with hierarchy
    def self.tree_root options={}
      user_hash = get(:tree_root, :params => options.reverse_merge({:set_actions => true}))
      User.user_with_hierarchy(user_hash)
    end

    def self.meta_details
      get(:meta_details).map{|opt| Tibbr::MetaInfo.new(opt)}.sort_by{|m| m.position.try(:to_f)}
    end

    def self.meta_details_for attr
      meta_details.select { |md| md.key.to_s == attr.to_s }.first
    end
    #  def rest_connection
    #    @rest_connection =  RestClient::Resource.new(TibbrResource.site) unless defined?(@rest_connection)
    #    @rest_connection
    #  end
    #
    #  def rest_payload
    #    {}.tap { |p| attributes.each {|k, v| p["#{User.element_name}[#{k}]"] = v unless v.is_a?(Array) or v.is_a?(Hash) or v.is_a?(TibbrResource)} }
    #  end
  
    #  def multi_part?
    #     attributes.any?{|k, v| v.respond_to?(:read) and v.respond_to?(:path) }
    #  end

    def self.objects_by_ids options={}
      get(:objects_by_ids,:params=>options)
    end


    def self.search_subjects id, s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get("#{id}/search_subjects", :params => {:set_actions => true, :page=>page, :per_page=>per_page}.merge(s_filters||{})), Subject)
    end

    class Facet
      attr_accessor :value
      attr_accessor :count
      def initialize v, c
        @value, @count = v, c
      end
    end

    class << self

      # Returns the last message id in the messages list
      def last_message messages
        #messages.inject(0) { |max, pm| pm.messages.inject(max > pm.id ? max : pm.id){|mx, cm| mx > cm.id ? mx : cm.id } }
        # Commented above line after adding sort_id column in the DB
        messages.inject(0) { |max, pm| max > pm.sort_id ? max : pm.sort_id }
      end

      def messages_since msgs, messages_since_id
        #[].tap { |list| msgs.each { |pm| (  (pm.id > messages_since_id or !(pm.messages.select{|cm| cm.id > messages_since_id}.empty?)) and (list << pm) )}}.sort {|a, b| a.id <=> b.id}
        # Commented above line after adding sort_id column in the DB
        [].tap { |list| msgs.each { |pm| (  (pm.sort_id > messages_since_id ) and (list << pm) )}}.sort {|a, b| a.id <=> b.id}
      end
  
      def find_by_auth_token
        begin
          User.new(get(:find_by_auth_token))
        rescue Exception => msg
          return nil
        end
      end
  
      def find_by_session
        begin
          User.new(get(:find_by_session))
        rescue Exception => msg
          return nil
        end
      end

      def get_access_token user_id, options
        begin
          User.new(get("#{user_id}/access_token", options))
        rescue Exception => msg
          return  nil
        end
      end

      def find_by_access_token
        begin
          puts "op"
          puts "dzrrggggg #{get(:find_by_access_token)}"
          User.new(get(:find_by_access_token))
        rescue Exception => msg
          puts "ERROR !!!! #{msg}"
          return nil
        end
      end
      
      def find_by_password_reset_code password_reset_code
        User.find(:first, :params => {:conditions=>{:password_reset_code=>password_reset_code}})
      end

      def find_by_login login
        User.new(get(:find_by_login, :params => {:login => login, :set_actions => true}))
      rescue ActiveResource::ResourceInvalid => error
        User.new.tap{|u| u.populate_error(error)}
      end

      def find_by_email email
        User.new(get(:find_by_email, :params => {:email => email, :set_actions => true}))
      rescue ActiveResource::ResourceInvalid => error
        User.new.tap{|u| u.populate_error(error)}
      end

      def find_all_by_ldap_group_id group_id
        groups_users = get(:find_all_by_ldap_group_id, :params => {:group_id => group_id, :set_actions => true})
        groups_users.collect{|user_entry| User.new(user_entry)} || []
      end

      def fuck options
        User.post(:login, {}, {'params' => options}.to_json)
      end

      # Authenticates with given credentials.
      # Returns the authenticated user upon success.
      # Throws ActiveResource::ServerError exception on error.
      def login usr, pwd, register_auth_token = false, remember_me = false, chat_connect = false, options={}
        options = options.dup.delete_if {|k, v| [:controller, :action, :format].include? k}
        begin
          opts = options.merge(:login => usr, :password => pwd, :remember_me => remember_me,
            :assertion_consumer_service_url => Tibbr::TibbrResource.assertion_consumer_service_url)
          #This needs to be done coz to_xml and to_json do not take same arguments.
          #We can write a custom patch on to_json to achieve this in future and to DRY the serialization code
          payload = case(format)
          when ActiveResource::Formats::JsonFormat
            {'params' => opts}.to_json
          else
            opts.to_xml(:root => 'params').to_s
          end
          res = User.post(:login, {}, payload)
          return nil unless res.instance_of?(Net::HTTPOK)
          User.new(format.decode(res.body)).tap do |u|
            if register_auth_token
              Tibbr::TibbrResource.auth_token = u.auth_token
              Tibbr::TibbrResource.tenant_name = u.tenant.name
            end
            u.chat_jid, u.chat_sid, u.chat_rid = chat_connect(usr, pwd) if chat_connect
          end
        rescue ActiveResource::BadRequest
          return nil
        end
      end

      # alias for the restful_authentication plugin
      alias :authenticate :login
      #  alias :find_by_id :find

      def login_redirect_url
        begin
          url_response = nil
          # url_response["url"] is always nil in case of default or ldap mode where we don't have to make multiple requests to server so we are caching the result here.
          # in case of SAML and SSO the login redirect URL keeps changing so we will not cache it instead making a request to get the login_redirect_url every time.
          url_response =  get(:login_redirect_url, {:params => {:assertion_consumer_service_url => Tibbr::TibbrResource.assertion_consumer_service_url}}) unless(@@res)
          @@res ||= url_response if url_response.present? && url_response.is_a?(Hash) && url_response.has_key?("url") && url_response["url"].blank?
        rescue Exception=>e
          logger.info(" --------> Error: #{e}")
        end
        @@res ? @@res["url"] : ((url_response.present? && url_response.is_a?(Hash)) ? url_response["url"] : "")
      end

      def chat_connect(user, password, options={})
        jid = "#{user}@#{Thread.current[:tenant] ? (Thread.current[:tenant]) : Tibbr::TibbrResource.chat_domain}"
        jid = "#{jid}/bosh_#{options[:resource]}" if options[:resource].present?
        RubyBOSH.initialize_session(jid, password, Tibbr::TibbrResource.chat_url)
      rescue Exception => ex
        logger.info("Error while authenticating the chat session for user(#{user}): #{ex}")
        [nil, nil, nil]
      end

      # Authenticates with the chat server using the auth-token or remember-token
      def chat_reconnect(user, options={})
        auth_token = options[:auth_token] || Tibbr::TibbrResource.auth_token
        remember_token = options[:remember_token] || Tibbr::TibbrResource.remember_token
        password = if auth_token.present?
          "<auth-token>#{auth_token}</auth-token><client-key>#{Tibbr::TibbrResource.client_key}</client-key>"
        elsif remember_token.present?
          "<remember-token>#{remember_token}</remember-token>"
        else
          nil
        end
        return [nil, nil, nil] if password.nil?
        chat_connect(user, password, options)
      end

      # When an array is passed returns a hash of the with name as key and status as value

      def chat_status(logins)
        if (logins.is_a?(String))
          users = [logins]
        elsif(logins.is_a?(Array))
          users = logins
          return {} if users.blank?
        else
          return {}
        end
        begin
          require 'net/http'
          url = URI.parse(Tibbr::TibbrResource.chat_url[/^.*\//] + "status")
          req = Net::HTTP::Get.new(url.path + "?users="+users.join(",") + "&tenant=#{Thread.current[:tenant] ? (Thread.current[:tenant]) : Tibbr::TibbrResource.chat_domain}")
          res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
        rescue EOFError
          res = nil
        rescue Errno::ECONNREFUSED => ex
          res = nil
        end
        r   = users.inject({}){|h, u| h[u] = "offline";h} # initialize the reply hash
        if (res.is_a?(Net::HTTPOK) &&
              (m = res.body.match(/<status>(.*)<\/status>/)) &&
              !m[1].blank?)
          m[1].split(",").each{|key| nv = key.split(":"); r[nv[0]] = nv[1]}
        end
        # return the status if the logins is a string. else return the hash
        logins.is_a?(String) ? r[logins] : r
      end

      # Returns the user with the given remember_token
      # Throws ActiveResource::ServerError exception on error
      #  def find_by_remember_token remember_token
      #    User.find(:first, :params => {:conditions=>{:remember_token=>remember_token}})
      #  end
      #
  

      def activate code
        (User.new(:id=> code)).put(:activate).instance_of?(Net::HTTPOK)
      end

      # Returns a 'User object containing errors' or 'nil' in case of failure
      # Returns an 'User object with empty errors' in case of success
      # The returned User object is not to be used for any purpose other than checking the errors
      def initiate_reset_password email
        put(:initiate_reset_password, :params => {:email => email}).instance_of?(Net::HTTPOK) ? User.new : nil
      rescue ActiveResource::ResourceInvalid => error
        User.new.tap{|u| u.populate_error(error)}
      end

      # Returns a 'User object containing errors' or 'nil' in case of failure
      # Returns an 'User object with empty errors' in case of success
      # The returned User object is not to be used for any purpose other than checking the errors
      def reset_password reset_code, password, password_confirmation
        put(:reset_password, :params => {:reset_code => reset_code, :password => password, :password_confirmation => password_confirmation}).instance_of?(Net::HTTPOK) ? User.new : nil
      rescue ActiveResource::ResourceInvalid => error
        User.new.tap{|u| u.populate_error(error)}
      end

      # ==== Options
      # Pagination options can be supplied using following parameters
      # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
      # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
      def explore_subjects *args
        page, per_page = TibbrResource.extract_params(args, 2)
        Subject.find(:all, :params => {:page=>page, :per_page=>per_page, :conditions => [ "subjects.scope = ? and subjects.stype = ? ", :public, :custom ],  :include => :message_subjects, :order => "message_subjects.id DESC" })
      end

      def cache_lookup cache_key, list_name=nil, page = 1, per_page = TibbrResource.per_page
        return nil unless page == 1
        u=TibbrResource.tcache.read(cache_key)
        return u if u.nil? or list_name.nil?
        list = u.attributes[list_name]
        return nil if list.nil?
        (list.per_page >= per_page) ? (list[((page-1)*per_page)...(page*per_page)]).paginate(:per_page => per_page, :total_entries => list.total_entries) : nil
      end

      BROADCAST_MESSAGE_LIST = "tibbr::user::broadcast_messages"
      BROADCAST_LAST_MESSAGE_ID = "tibbr::user::broadcast_last_message_id"

      def cache_add_broadcast_msg msg
        messages = TibbrResource.tcache.read(BROADCAST_MESSAGE_LIST) || []
        messages.insert(message_pos(messages, msg), msg)
        messages.pop if messages.size > 50
        TibbrResource.tcache_write(BROADCAST_MESSAGE_LIST, messages)
        last_message_id = TibbrResource.tcache.read(BROADCAST_LAST_MESSAGE_ID) || 0
        TibbrResource.tcache_write(BROADCAST_LAST_MESSAGE_ID, msg.id) if msg.id > last_message_id
      end
  
      def broadcast_msg_since id
        last_message_id = TibbrResource.tcache.read(BROADCAST_LAST_MESSAGE_ID) || 0
        return [].paginate(:per_page => TibbrResource.per_page) if id >= last_message_id
        messages = TibbrResource.tcache.read(BROADCAST_MESSAGE_LIST) || [].paginate(:per_page => TibbrResource.per_page)
        messages.select {|m| m.id > id}
      end
  
      def message_pos messages, msg
        mpos = 0
        while (messages[mpos].id > msg.id)
          mpos +=1
        end unless messages.empty?
        mpos
      end
  
      def cache_add cache_key, obj, list_name=nil, page = 1, options={}
        return false unless page == 1 # for the time being we are caching the first page
        return ((obj.cached = true) and TibbrResource.tcache_write(cache_key, obj)) if list_name.nil?
        (u = cache_lookup(cache_key)) and                                         # get the object
        (list = (u.attributes[list_name] ||=[].paginate(:per_page => TibbrResource.per_page))) and                            # get the list. Initialize the list if null
        cache_add_to_list(u, list, obj, list_name, options) and                                     # add the object to the list
        u.attributes[list_name]= list and                                       # Update the list in the user object
        u.cache_add(u)                                                          # Update the cache
      end

      def cache_add_to_list u, list, item, list_name, options={}
        if item.is_a?(Array)
          item.each{|obj| cache_add_to_list2(u, list, obj, list_name, options)}
        else
          cache_add_to_list2(u, list, item, list_name, options)
        end
        true
      end

      def cache_add_to_list2 u, list, obj, list_name, options={}
        obj_added, broadcast_msg = false, (obj.class == Tibbr::Message and obj.broadcast)
        if obj.attributes["parent_id"].blank?
          if (o = list.find{|x| x.id == obj.id})
            list[list.index(o)] = obj
          elsif(!options[:only_update_if_exists])
            list.insert(broadcast_msg ? message_pos(list, obj) : 0, obj)
            list.total_entries = list.total_entries + 1 if list.respond_to?(:total_entries)
            list.pop if list.size > list.per_page
            obj_added = true
          end
        else
          p = list.find{|x| x.id == obj.parent_id} # find the parent
          return true unless p
          clist = (p.attributes[list_name] ||=[])
          if (co = clist.find{|x| x.id == obj.id})
            clist[clist.index(co)] = obj
          elsif(!options[:only_update_if_exists])
            clist.insert(broadcast_msg ? message_pos(clist, obj) : 0, obj)
            p.replies_count += 1      #updating replies_count when adding new reply in cache
            list[list.index(p)] = p
            obj_added = true
          end
        end
        u.v_last_broadcast_message_id = obj.id if obj_added and broadcast_msg
        return true
      end

      def cache_remove cache_key, list_name=nil, obj = nil, page = 1
        return TibbrResource.tcache.delete(cache_key) if list_name.nil?
        (u = cache_lookup(cache_key)) and !(list = cache_lookup(cache_key, list_name)).nil? and
          (obj.nil? ? ((list = nil) or true) : # User wants to delete the list
          (
            obj.attributes["parent_id"].blank? ?
              (
              (o = list.find{|x| x.id == obj.id}) and list.delete_at(list.index(o)) # find and delete
            ) :
              ( # if object has a parent
              (p = list.find{|x| x.id == obj.parent_id}) and # find parent
              !(clist = p.attributes[list_name]).empty? and # get the children list
              ((co = clist.find{|x| x.id == obj.id}) and clist.delete_at(clist.index(co))) # find and delete the child
            )
          )
        ) and ((u.attributes[list_name] = list) or true) and u.cache_add(u) # add the updated object back to cache
      end
		  
      def list_exchange_contacts *args
        page, per_page, options = TibbrResource.extract_params(args, 2)
        post(:list_exchange_contacts, :params => {:page=>page, :per_page=>per_page, :exchange => {:username => options[:username],:password => options[:password],:domain => options[:domain]}})
      end
	
      def list_contact_from_GAL *args
        page, per_page, options = TibbrResource.extract_params(args,2)
        post(:list_contact_from_GAL, :params => {:page=>page, :per_page=>per_page, :exchange => {:username => options[:username],:password => options[:password],:domain => options[:domain]}, :search_string =>options[:search_string]})
      end

    end

    #    def meta_details
    #      get(:meta_details)
    #    end

    def cache_lookup user_para=nil, list_name=nil, page = 1, per_page = TibbrResource.per_page
      obj_lookup(user_para, list_name, page, per_page) || ((self.id == get_user_id(user_para)) ? User.cache_lookup(self.cache_key, list_name, page, per_page) : nil )
    end

    def cache_add obj, user_id=nil, list_name=nil
      User.cache_add(self.cache_key, obj, list_name) if (self.id.to_s == (user_id || self.id).to_s)
    end

    def cache_remove user_id=nil, list_name=nil, obj = nil, page = 1
      User.cache_remove(self.cache_key, list_name, obj, page) if (self.id.to_s == (user_id || self.id).to_s)
      attributes.delete(list_name) unless list_name.blank?
    end
  
    def last_message
      m = attributes['message']
      return m unless self.broadcast?
      bmsg = Tibbr::User.broadcast_msg_since(self.v_last_broadcast_message_id)[0]
      (bmsg.nil? or m.id >= bmsg.id) ? m : bmsg
    end

    # returns the last n messages sent by the current user.
    # by default returns the last message sent by the user.
    def last_n_messages n = 1
      messages(:per_page => n, :page => 1)
    end
  
    def subscription_requests *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      user_id ||= self.id
      cache_lookup(user_id, "subscription_requests", page, per_page) ||
        TibbrResource.paginate_collection(get(:subscription_requests, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), SubscriptionRequest)
    end

    def invited_subjects *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      user_id ||= self.id
      cache_lookup(user_id, "invited_subjects", page, per_page) ||
        TibbrResource.paginate_collection(get(:invited_subjects, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), Subject)
    end

    # Returns the auto subjects associated with the user visible to the user with id = user_id
    # ==== Arguments
    # The first argument is user_id
    # ==== Throws
    # Throws ActiveResource::ServerError exception on error
    def auto_subjects *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      cache_lookup(user_id, "auto_subjects", page, per_page) ||
        TibbrResource.paginate_collection(get(:subjects, :params => {:set_actions => true, :user_id => user_id, :auto_subjects => true, :page=> 1, :per_page=>per_page}), Subject)
    end

    # Returns an User object (with id=user_id).
    # ==== Arguments
    # The first argument is user_id. When nil self.id is used as user_id
    # ==== Returns
    # * User object. The object will have an array attribute: 'actions'.
    # * This attribute holds the valid actions on the object by the current user.
    # * <tt>actions</tt> -- [subscribe|unsubscribe], [pause|play], [block_subject|unblock_subject]
    # * * [block|unblock]   -- self
    # * * [follow|unfollow] -- other
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def find_user_for_me *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      user_id = self.id if user_id.blank?
      #    raise ActiveResource::BadRequest if user_id.blank?
      cache_lookup(user_id) || User.new.tap do |u|
        r = User.get(user_id.to_s, :set_actions => true, :user_id => self.id, :profile => :complete, :page => page, :per_page => per_page)
        u.subjects      = TibbrResource.paginate_collection(r.delete("subjects"), Subject)
        u.auto_subjects = TibbrResource.paginate_collection(r.delete("auto_subjects"), Subject)
        u.subscriptions = TibbrResource.paginate_collection(r.delete("subscriptions"), Subject)
        u.channels      = TibbrResource.paginate_collection(r.delete("channels"), Channel)
        u.followers     = TibbrResource.paginate_collection(r.delete("followers"), User)
        u.idols         = TibbrResource.paginate_collection(r.delete("idols"), User)
        u.schedules     = TibbrResource.paginate_collection(r.delete("schedules"), User)
        u.messages      = TibbrResource.paginate_collection(r.delete("messages"), Message)
        u.annoucements  = TibbrResource.paginate_collection(r.delete("announcements"), Message)
        u.subscription_requests      = TibbrResource.paginate_collection(r.delete("subscription_requests"), SubscriptionRequest)
        u.message_filters = TibbrResource.paginate_collection(r.delete("message_filters"), MessageFilter)
        u.communities    = TibbrResource.paginate_collection(r.delete("communities"), Community)
        u.invited_subjects = TibbrResource.paginate_collection(r.delete("invited_subjects"), Subject)
        u.global_announcements = TibbrResource.paginate_collection(r.delete("global_announcements"), Message)
        u.follower_requests = TibbrResource.paginate_collection(r.delete("follower_requests"), FollowerRequest)
        u.badges        = (r.delete("badges")||{}).symbolize_keys
        u.is_admin      = r.delete("is_admin")
        u.viewer_id     = self.id
        u.v_page        = page
        u.v_per_page    = per_page
        u.v_last_broadcast_message_id    = 0
        u.load(r)
      end.tap {|o| cache_add(o, user_id)}
      #    User.find(user_id, :params => {:set_actions => true, :user_id => self.id, :profile => :complete})
    end

    # Returns an Subject object (with id=subject_id).
    # ==== Arguments
    # The first argument is subject_id
    # ==== Returns
    # * Subject object. The object will have an array attribute: 'actions'.
    # * This attribute holds the valid actions on the object by the current user.
    # * <tt>actions</tt> -- [subscribe|unsubscribe], [pause|play], [delete]
    # * * [block|unblock]   -- self
    # * * [follow|unfollow] -- other
    # * * [delete]          -- owner
    # * * The object will have a User object attribute: 'user'.
    # * * This attribute holds the User object for the subject owner.
    # * Subject has
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def find_subject_for_me *args
      subject_id, page, per_page = TibbrResource.extract_params(args)
      raise ActiveResource::BadRequest if subject_id.blank?
      Subject.new.tap do |s|
        r = Subject.get(subject_id.to_s, :params => {:profile => :complete, :set_actions => true, :page => page, :per_page => per_page})
        s.subscribers   = TibbrResource.paginate_collection(r.delete("subscribers"), User)
        s.subscriber_groups  = TibbrResource.paginate_collection(r.delete("subscriber_groups"), Group)
        s.messages      = TibbrResource.paginate_collection(r.delete("messages"), Message)
        s.assets        = TibbrResource.paginate_collection(r.delete("assets"), Asset)
        s.links         = TibbrResource.paginate_collection(r.delete("links"), Link)
        s.announcements = TibbrResource.paginate_collection(r.delete("announcements"), Message)
        s.question_messages = TibbrResource.paginate_collection(r.delete("question_messages"), Message)
        s.calendar_messages = TibbrResource.paginate_collection(r.delete("calendar_messages"), Message)
        s.subject_children      = TibbrResource.paginate_collection(r.delete("subject_children"), Subject)
        s.owners        = TibbrResource.paginate_collection(r.delete("owners"), User)
        s.pages = TibbrResource.paginate_collection(r.delete("pages"), Page)
        s.viewer_id     = self.id
        s.v_page        = page
        s.v_per_page    = per_page
        s.load(r)
      end
    end

    # Returns an Group object (with id=group_id).
    # ==== Arguments
    # The first argument is subject_id
    # ==== Returns
    # * Group object. The object will have an array attribute: 'actions'.
    # * This attribute holds the valid actions on the object by the current user.
    # * <tt>actions</tt> -- [subscribe|unsubscribe], [pause|play], [delete]
    # * * [block|unblock]   -- self
    # * * [follow|unfollow] -- other
    # * * [delete]          -- owner
    # * * The object will have a User object attribute: 'user'.
    # * * This attribute holds the User object for the subject owner.
    # * Subject has
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def find_group_for_me *args
      group_id, page, per_page = TibbrResource.extract_params(args)
      raise ActiveResource::BadRequest if group_id.blank?
      Group.new.tap do |g|
        r = Group.get(group_id.to_s, :params => {:profile => :complete, :set_actions => true, :page => page, :per_page => per_page})
        g.followers   = TibbrResource.paginate_collection(r.delete("followers"), User)
        g.actions     = Array.new(r.delete("actions").split(",").map{|a| a.strip})
        g.viewer_id   = self.id
        g.v_page      = page
        g.v_per_page  = per_page
        g.load(r)
      end
    end

    # Returns the search summary of owners and subjects for the given query
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # ** search_str, defaults to ""
    # ** subject_id, defaults to nil
    # ** user_id,    defaults to nil
    # ==== Options

    # Returns count of users and subjects for a given mode.
    # E.g.: To find the count of users and subjects based on the messages sent:
    #   u.explore_users(:mode=>:message, :duration => :today)  # for messages sent today
    #   u.explore_users(:mode=>:message, :duration => :week)   # for messages sent in last 7 days
    #   u.explore_users(:mode=>:message, :duration => :month)  # for messages sent in last 30 days
    #   u.explore_users(:mode=>:message, :duration => :all)    # for all messages sent
    #
    #   Supported modes are message, subject, and follower
    # ==== Arguments
    # Arguments are passed as options. Expected options varies according to the mode.
    # :mode =  :message, :subject, :follower ; Defaults to :message
    # for mode = :message
    #   :duration   = :today, :yesterday, :week, :month, :all ; Defaults to :today
    #   :subject_id = Defaults to nil
    #
    # ==== Options Common to All modes
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Hash
    # *  :owner
    # * *   Array of User::Facet objects. Each Facet object contains the User object as value.
    # *  :subject
    # * *   Array of User::Facet objects. Each Facet object contains the Subject object as value.
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def explore_users options={}
      options = {:mode => :message, :duration => :today, :page => 1, :per_page => TibbrResource.per_page}.merge(options)
      r = get(:explore_users, :params => options)
      {}.tap do |hash|
        hash[:subject]  = (r["subject"] || []).collect {|p| Facet.new(Subject.new(p["facet"]), p["count"])}
        hash[:owner]    = (r["owner"] || []).sort{|a, b| b["count"] <=> a["count"]}.paginate(:page => options[:page], :per_page => options[:per_page]).tap {|list| list.replace(list.collect {|p| Facet.new(User.new(p["facet"]), p["count"])})}
        #      hash[:owner]    = TibbrResource.paginate_collection(r["owner"]) {|p| Facet.new(User.new(p["facet"]), p["count"])} #TODO this should be final version
        #      hash[:owner]    = (r["owner"] || []).collect {|p| Facet.new(User.new(p["facet"]), p["count"])}
        #      users           = (r["owner"] || []).collect {|p| Facet.new(User.new(p["facet"]), p["count"])}
        #      #TODO result should be a paginated list. Time being we are faking it
        #      hash[:owner]    = WillPaginate::Collection.create(1, users.length, users.length) do |pager|
        #        pager.replace users
        #      end
      end
    end

    attr_accessor :is_admin
    def is_admin
      (@is_admin.blank? ? (get(:is_admin)||{})["result"] : @is_admin).to_bool
    end

    def impersonate?
      @impersonate = (get(:can_impersonate)||{})["result"] unless defined?(@impersonate)
      @impersonate
    end

    def make_admin usr_id
      (User.new(:id=> usr_id)).put(:make_admin).instance_of?(Net::HTTPOK)
    end

    # Returns an array of Messages matching the search string and the optional subject id
    # and user_id.
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # ** search_str, defaults to ""
    # ** subject_id, defaults to nil
    # ** user_id,    defaults to nil
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # * <tt>:message_filter_id</tt> -- defaults to nil. If provided, then the message_filter criteria will be added to the search
    # * <tt>:greater_than_id</tt> -- defaults to nil. If provided, then only the messages with id greater than this will be searched
    # * <tt>:less_than_id</tt> -- defaults to nil. If provided, then only the messages with id less than this will be searched
    # * <tt>:mtype</tt> -- defaults to nil. If provided, then only the messages this mtype will be searched
    # * <tt>:exclude_mtype</tt> -- defaults to nil. If provided, then only the messages without this mtype will be searched
    # ==== Returns
    # * Array of Messages.
    # * *   Each object will have an array attribute: 'actions'.
    # * * This attribute holds the valid actions on the object by the current user.
    # * * <tt>actions</tt> -- reply
    # * * * * [reply]   -- all
    # * *   Each object will have a User object attribute: 'user'.
    # * * This attribute holds the User object for the Message owner.
    # * *   If will_paginate plugin is installed, then the return Array will be
    # * * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def message_search *args
      search_str, subject_id, user_id, page, per_page, options = TibbrResource.extract_params(args, 5)
      message_filter_id = options[:message_filter_id]
      page = 1 unless options[:start_after].blank?    #enforce page = 1 if start_after parameter is used.
      greater_than_id = options[:greater_than_id]
      less_than_id = options[:less_than_id] || options[:start_after]
      mtype = options[:mtype]
      lat = options[:lat]
      lng = options[:lng]
      range = options[:range]
      exclude_mtype = options[:exclude_mtype]
      include_replies = options[:include_replies] || nil
      advanced_search_filter = options[:advanced_search_filter]
      like_by = options[:like_by]       
      message_tag = options[:message_tag]
      star_by = options[:star_by]
      question_answered_by = options[:question_answered_by]
      order_by = options[:order_by]
      TibbrResource.paginate_collection(get(:message_search, :params => {:set_actions => true,
            :search_str => search_str, :subject_id => subject_id, :user_id => user_id,
            :message_filter_id => message_filter_id, :greater_than_id => greater_than_id,
            :less_than_id => less_than_id, :mtype => mtype, :exclude_mtype => exclude_mtype,
            :page=>page, :per_page=>per_page, :include_replies=>include_replies,
            :advanced_search_options => advanced_search_filter,
            :like_by => like_by, :message_tags => message_tag,
            :star_by => star_by,
            :question_answered_by => question_answered_by,
            :lat => lat, :lng => lng, :range => range,
            :order_by => order_by}), Message)
    end

    # Returns the search summary of owners and subjects for the given query
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # ** search_str, defaults to ""
    # ** subject_id, defaults to nil
    # ** user_id,    defaults to nil
    # ** message_filter_id, defaults to nil. If provided, then the message_filter criteria will be added to the search
    # ==== Options
    # ==== Returns
    # * Hash
    # *  :owner
    # * *   Array of User::Facet objects. Each Facet object contains the User object as value.
    # *  :subject
    # * *   Array of User::Facet objects. Each Facet object contains the Subject object as value.
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def message_facets search_str, subject_id=nil, user_id=nil, message_filter_id=nil, options={}
      message_tags = options[:message_tags]
      {}.tap do |hash|
        r = get(:message_facets, :params => {:search_str => search_str,
            :subject_id => subject_id, 
            :user_id => user_id,
            :message_filter_id => message_filter_id,
            :message_tags => message_tags})
        hash[:subject]  = (r["subject"] || []).collect {|p| Facet.new(Subject.new(p["facet"]), p["count"])}
        hash[:owner]  = (r["owner"] || []).collect {|p| Facet.new(User.new(p["facet"]), p["count"])}
      end
    end

    # Returns an array of Users matching the search string and the optional parameters.
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # Hash of Search Filters. The hash can contain the following
    # For generic search:
    # ** search_str, defaults to nil. Searches through all the users text attributes (i.e. :description, :login, :first_name, :last_name, :email, :department, :city, :zip, :country).
    # For field specific search:
    # ** login, defaults to nil
    # ** first_name, defaults to nil
    # ** last_name, defaults to nil
    # ** email, defaults to nil
    # ** department, defaults to nil
    # ** city, defaults to nil
    # ** country, defaults to nil
    # ** zip, defaults to nil
    # ** followers, defaults to nil
    # ** following, defaults to nil
    # ** subscriptions, default to nil
    # ** role_memberships, default to nil
    #
    # Use 'exclude_field' (e.g. :exclude_login, :exclude_followers) to add negation conditions. This does not apply for :search_str.
    # Use 'starts_with_field' (e.g. :starts_with_login, :starts_with_first_name) to add starts with conditions. This applies only for :login, :first_name & :last_name.
    # Use 'include_deleted' (e.g. :include_deleted => true) to include the deleted users which match the search query.
    # Use 'include_deactivated' (e.g. :include_deactivated => true) to include the deactivated users which match the search query.
    # 
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Users.
    # * *   Each object will have a Message object attribute: 'message'.
    # * * This attribute holds the last message posted by the User.
    # * *   If will_paginate plugin is installed, then the return Array will be
    # * * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    # ==== Examples
    # user.search_users()  => No filter conditions; Searches for All users
    # user.search_users({:search_str => 'tom'})  => Searches for users which have the keyword 'tom' in any of the text fields (i.e. in :description, :login, :first_name, :last_name, :email, :department, :city, :zip, :country)
    # user.search_users({:followers => 5}, {:page => 3, :per_page => 20}) => Search for users which have user_id=5 as a follower
    # user.search_users({:exclude_subscriptions => [1,8,13]})  => Search for subjects which do not have user_ids 1,8 & 13 as followers
    # user.search_users({:exclude_role_memberships => [1,8,13]})  => Search for users which do not have role_ids 1,8 & 13
    def search_users s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args, 2)
      TibbrResource.paginate_collection(get(:search_users, :params => {:set_actions => true, :page=>page, :per_page=>per_page}.merge(s_filters||{})), User)
    end

    # Returns an array of Subjects matching the search string and the optional parameters.
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # Hash of Search Filters. The hash can contain the following
    # For generic search:
    # ** search_str, defaults to nil. Searches through all the subjects text attributes (i.e. name & description).
    # For field specific search:
    # ** name, defaults to nil  e.g. 'tibbr.help' will match the subject with name 'tibbr.help'
    # ** sname, defaults to nil e.g. 'help' will match the subject with name 'tibbr.help'
    # ** scope, defaults to nil e.g. 'public','private','protected'
    # ** stype, defaults to nil e.g. 'custom','system'
    # ** owner_id, defaults to nil
    # ** created_after, defaults to Time.now e.g. "2010-08-20"
    # ** created_before, defaults to Time.now  e.g. "2010-08-18"
    # ** subscribers, defaults to nil
    #
    # Use :exclude_field (e.g. :exclude_scope, :exclude_owner_id) to add negation conditions. This does not apply for :search_str.
    # Use :starts_with_field (e.g. :starts_with_sname, :starts_with_name) to add starts with conditions. This applies only for :name & :sname.
    # Use :include_deleted (e.g. :include_deleted => true) to include the deleted subjects which match the search query.
    # Use :include_inaccessible (e.g. :include_inaccessible => true) to include the inaccessible subjects (i.e. private) which match the search query.
    # Use :only_postable (e.g. :only_postable => true) to restrict to subjects to which the user can post.
    #
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Users.
    # * *   Each object will have a Message object attribute: 'message'.
    # * * This attribute holds the last message posted by the User.
    # * *   If will_paginate plugin is installed, then the return Array will be
    # * * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    #
    # ==== Examples
    # user.search_subjects()  => No filter conditions; Searches for All subjects
    # user.search_subjects({:search_str => 'help'})  => Searches for subjects with have the keyword 'help' in any of its text fields (i.e. in name & description).
    # user.search_subjects({:subscribers => 5},{:per_page => 99}) => Search for subjects which have user_id=5 as a subscriber
    # user.search_subjects({:exclude_subscribers => [1,3,65]})  => Search for subjects which do not have user_ids 1,3 & 65 as subscribers
    def search_subjects s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get(:search_subjects, :params => {:set_actions => true, :page=>page, :per_page=>per_page}.merge(s_filters||{})), Subject)
    end

    def search_groups s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get(:search_groups, :params => {:set_actions => true, :page=>page, :per_page=>per_page}.merge(s_filters||{})), Group)
    end

    def search_subject_assets s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get(:search_subject_assets, :params => {:page=>page, :per_page=>per_page}.merge(s_filters||{})), Asset)
    end

    def search_subject_links s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get(:search_subject_links, :params => {:page=>page, :per_page=>per_page}.merge(s_filters||{})), Asset)
    end
    # Returns an array of Roles matching the search string and the optional parameters.
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # Hash of Search Filters. The hash can contain the following
    # For generic search:
    # ** search_str, defaults to nil. Searches through all the roles text attributes (i.e. display_name & description).
    # 
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Roles.
    #
    # ==== Examples
    # user.search_roles()  => No filter conditions; Searches for All roles
    # user.search_roles({:search_str => 'super_user'})  => Searches for roles with have the keyword 'super_user' in any of its text fields (i.e. in display_name & description).
    # user.search_roles({:search_str => 'my description'},{:per_page => 99}) => Searches for roles with have the keywords 'my description' in any of its text fields (i.e. in display_name & description).
    def search_roles s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get(:search_roles, :params => {
            :page=>page, :per_page=>per_page,
            :include_members => true, :include_privileges => true}.merge(s_filters||{})), Role)
    end

    # Returns an array of ApplicationInstances matching the search string and the optional parameters.
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # Hash of Search Filters. The hash can contain the following
    # For generic search:
    # ** search_str, defaults to nil. Searches through all the roles text attributes (i.e. name & owners_name).
    #
    # Use :include_deleted (e.g. :include_deleted => true) to include the deleted application_instances which match the search query.
    # 
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Roles.
    #
    # ==== Examples
    # user.search_application_instances()  => No filter conditions; Searches for All roles
    # user.search_application_instances({:search_str => 'ruby discussions'})  => Searches for application_instances with have the keyword 'super_user' in any of its text fields (i.e. name & owners_name).
    # user.search_application_instances({:search_str => 'tom'},{:per_page => 99}) => Searches for application_instances with have the keywords 'my description' in any of its text fields (i.e. name & owners_name).
    def search_application_instances s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      #FIXME: I doubt if below type-casting will work =>
      TibbrResource.paginate_collection(get(:search_application_instances, :params => {:page=>page, :per_page=>per_page}.merge(s_filters||{})), ApplicationInstance)
    end

    def search_application_definitions s_filters={}, *args
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection(get(:search_application_definitions, :params => {:page=>page, :per_page=>per_page}.merge(s_filters||{})), ApplicationDefinition)
    end

    #arguments same as search_users
    #optional parameter :value_type => 'id' or 'login'.
    def list_users s_filters={}, *args
      page, per_page, options = TibbrResource.extract_params(args, 2)
      value_type = options[:value_type]||'id'
      get(:list_users, :params => {:page=>page, :per_page=>per_page, :value_type => value_type}.merge(s_filters||{}))
    end

    # Returns an array of LDAP groups matching the search string and the optional parameters.
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # Hash of Search Filters.
    def list_ldap_groups s_filters={}, *args
      page, per_page, options = TibbrResource.extract_params(args, 2)
      value_type = options[:value_type]||'id'
      get(:list_ldap_groups, :params => {:page=>page, :per_page=>per_page, :value_type => value_type}.merge(s_filters||{}))
    end
	

	
    #arguments same as search_subjects
    #optional parameter :value_type => or 'name'.
    def list_subjects s_filters={}, *args
      page, per_page, options = TibbrResource.extract_params(args, 2)
      value_type = options[:value_type]||'id'
      get(:list_subjects, :params => {:page=>page, :per_page=>per_page, :value_type => value_type}.merge(s_filters||{}))
    end

    def list_groups s_filters={}, *args
      page, per_page, options = TibbrResource.extract_params(args, 2)
      value_type = options[:value_type]||'id'
      get(:list_groups, :params => {:page=>page, :per_page=>per_page, :value_type => value_type}.merge(s_filters||{}))
    end

    #arguments same as search_subjects and search_users
    #:value_type is hardcoded to be 'name'/'login'.
    def list_message_targets s_filters_users={}, s_filters_subjects={}, *args
      page, per_page, options = TibbrResource.extract_params(args, 2)
      get(:list_message_targets, :params => {
          :users_filters => (s_filters_users||{}).reverse_merge({:page=>page, :per_page=>per_page}),
          :subjects_filters => (s_filters_subjects||{}).reverse_merge({:page=>page, :per_page=>per_page})})
    end

    def subject_trend
      tcache.fetch("subject_trend", :expires_in => 10.minutes) {(get(:subject_trend) || []).collect {|p| Facet.new(Subject.new(p["facet"]), p["count"])} }
    end

    # Returns a list schedules for the given user
    # ==== Arguments
    # user_id   : User being seen by the current user.
    #             Accepts user id/User object.
    # ==== Options
    # * <tt>:page</tt> - Current page. Defaults to 1.
    # * <tt>:per_page</tt> - Rows per page. Defaults to TibbrResource.per_page.
    #
    # ==== Examples
    #   user     = current_user.find_user_for_me(id)
    #   schedules = user.schedules(user)    # most efficient call
    #   schedules = user.schedules(user.id)
    #   schedules = user.schedules
    def schedules *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      cache_lookup(user_id, "schedules", page, per_page) ||
        TibbrResource.paginate_collection(get(:schedules, :params => {:set_actions => true, :page=>page, :per_page=>per_page}), Schedule)
    end
  
    # Returns a list channels for the given user
    # Returns a list channels for the given user and subject when subject is present.
    # ==== Arguments
    # user_id   : User being seen by the current user.
    #             Accepts user id/User object.
    # subject_id: Optional. When present returns the channels for
    #             the given subject for the given user.
    #             Accepts subject name/subject id/or Subject object.
    # ==== Options
    # * <tt>:page</tt> - Current page. Defaults to 1.
    # * <tt>:per_page</tt> - Rows per page. Defaults to TibbrResource.per_page.
    #
    # ==== Examples
    #   user     = current_user.find_user_for_me(id)
    #   channels = user.channels(user)    # most efficient call
    #   channels = user.channels(user.id)
    #   channels = user.channels
    #   s_channels = user.channels(user, subject.name)
    #   s_channels = user.channels(user, subject.id)
    #   s_channels = user.channels(user, subject)
    #   s_channels = user.channels(user, user.login)
    def channels *args
      user_id, subject_id, page, per_page = TibbrResource.extract_params(args, 4)
      subject_id = subject_id.id if subject_id.is_a?(ActiveResource::Base)
      (cache_lookup(user_id, "channels", page, per_page) if subject_id.nil?) ||
        TibbrResource.paginate_collection(get(:channels, :params => {:set_actions => true, :page=>page, :per_page=>per_page, :subject_id => subject_id}), Channel)
    end

    def subject_channels subject_id
      self.channels(self, subject_id)
    end

    def subject_channels_add subject_id, channels
      subject_channel_action :add, subject_id, channels
    end

    def subject_channels_delete subject_id, channels
      subject_channel_action :delete, subject_id, channels
    end


    # Returns a list schedules for the given channel
    # Returns a list schedules for the given channel and subject when subject is present.
    # ==== Arguments
    # channel_id  : id of the channel object
    # subject_id  : Optional.
    #             Accepts subject name/subject id/or Subject object.
    #             Passing the subject name is handy when trying to override the channels for
    #             following users.
    # ==== Examples
    #   user        = current_user.find_user_for_me(id)
    #   schedules   = user.channel_schedules(channel.id)
    #   s_schedules = user.channel_schedules(channel.id, subject.id)
    #   s_schedules = user.channel_schedules(channel.id, subject.name)
    #   s_schedules = user.channel_schedules(channel.id, subject)
    #   s_schedules = user.channel_schedules(channel.id, user.login)
    def channel_schedules(channel_id, subject_id=nil)
      subject_id = subject_id.id if subject_id.is_a?(ActiveResource::Base)
      TibbrResource.paginate_collection(get(:channel_schedules, :params => {:set_actions => true, :page=>1, :per_page=>99999, :channel_id => channel_id, :subject_id => subject_id}), Schedule)
    end
  
    # Replaces the schedules for the given channel
    # Replaces the schedules for the given channel and subject when subject is present.
    # ==== Arguments
    # schedules   : array of schedule objects OR array of schedule id's
    # channel_id  : id of the channel object
    # subject_id  : Optional.
    #             Accepts subject name/subject id/or Subject object.
    #             Passing the subject name is handy when trying to override the channels for
    #             following users.
    # ==== Examples
    #   user        = current_user.find_user_for_me(id)
    #   user.channel_schedules_replace(schedules.collect(&:id), channel.id)
    #   user.channel_schedules_replace(schedules, channel.id)
    #   user.channel_schedules_replace([], channel.id) #flushes the current schedules
    def channel_schedules_replace(schedules, channel_id, subject_id=nil)
      channel_schedules_action(:replace, schedules, channel_id, subject_id)
    end

    # Deletes the schedules for the given channel
    # Deletes the schedules for the given channel and subject when subject is present.
    # ==== Arguments
    # schedules   : array of schedule objects OR array of schedule id's
    # channel_id  : id of the channel object
    # subject_id  : Optional.
    #             Accepts subject name/subject id/or Subject object.
    #             Passing the subject name is handy when trying to override the channels for
    #             following users.
    # ==== Examples
    #   user        = current_user.find_user_for_me(id)
    #   user.channel_schedules_delete(schedules.collect(&:id), channel.id)
    #   user.channel_schedules_delete(schedules, channel.id)
    def channel_schedules_delete(schedules, channel_id, subject_id=nil)
      channel_schedules_action(:delete, schedules, channel_id, subject_id)
    end
  
    # Adds the schedules for the given channel
    # Adds the schedules for the given channel and subject when subject is present.
    # ==== Arguments
    # schedules   : array of schedule objects OR array of schedule id's
    # channel_id  : id of the channel object
    # subject_id  : Optional.
    #             Accepts subject name/subject id/or Subject object.
    #             Passing the subject name is handy when trying to override the channels for
    #             following users.
    # ==== Examples
    #   user        = current_user.find_user_for_me(id)
    #   user.channel_schedules_add(schedules.collect(&:id), channel.id)
    #   user.channel_schedules_add(schedules, channel.id)
    def channel_schedules_add(schedules, channel_id, subject_id=nil)
      channel_schedules_action(:add, schedules, channel_id, subject_id)
    end


    def channel_schedules_action(action, schedules, channel_id, subject_id=nil)
      schedule_ids = comma_seperated_ids(schedules)
      #    return false if schedule_ids.blank?
      subject_id = subject_id.id if subject_id.is_a?(ActiveResource::Base)
      put("channel_schedules_#{action}".to_sym, :params => {:schedule_ids => schedule_ids, :channel_id => channel_id, :subject_id => subject_id}).instance_of?(Net::HTTPOK)
    end
  

    # Returns an array of Subjects subscribed by the user(with id=user_id).
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # user_id, defaults to current user id
    # inherited, defaults to false. When true, inherited subscriptions are included in the result set.
    # include_self, defaults to true. When true, subscriptions to subjects created by the user are included in the result set.
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * array of Subjects. Each subject will have an array attribute: 'actions'.
    # * this attribute holds the valid actions on the subject by the current user.
    # * <tt>actions</tt> -- [subscribe|unsubscribe], [pause|play], [block_subject|unblock_subject]
    # * * [subscribe|unsubscribe] -- visitor without subscription
    # * * [pause|play]            -- visitor with subscription
    # * * [block_subject|unblock_subject]-- subject owner
    # * If will_paginate plugin is installed, then the return Array will be
    # * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def subscriptions *args
      user_id, inherited, include_self, page, per_page = TibbrResource.extract_params(args, 5)
      user_id ||= self.id
      # dont do cache lookup if inherited is true
      ((inherited == true ) ? nil : cache_lookup(user_id, "subscriptions", page, per_page)) ||
        TibbrResource.paginate_collection(get(:subscriptions, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page, :inherited => (inherited || false), :include_self => (include_self || true)}), Subject)
    end

    # Parameters
    #   user_id
    #   subject_id
    # Options
    #   msg_create
    #   msg_reply
    def subscription_rights user_id, subject_id, options = {}
      put(:subscription_rights, :params => {:user_id => user_id, :subject_id => subject_id }.merge(options)).instance_of?(Net::HTTPOK)
    end

    # Returns an array of Subjects created by the user(with id=user_id).
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # The first argument is user_id, defaults to current user id
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * array of Subjects. Each object will have an array attribute: 'actions'.
    # * this attribute holds the valid actions on the object by the current user.
    # * <tt>actions</tt> -- [subscribe|unsubscribe], [pause|play], delete
    # * * [subscribe|unsubscribe] -- visitor without subscription
    # * * [pause|play]            -- visitor with subscription
    # * * [delete]                -- subject owner
    # * If will_paginate plugin is installed, then the return Array will be
    # * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def subjects *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      user_id ||= self.id
      cache_lookup(user_id, "subjects", page, per_page) ||
        TibbrResource.paginate_collection(get(:subjects, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), Subject)
    end

    # Returns an array of Users followed by the user(with id=user_id).
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # The first argument is user_id, defaults to current user id
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * array of Users. Each object will have an array attribute: 'actions'.
    # * this attribute holds the valid actions on the object by the current user.
    # * * <tt>actions</tt> -- [follow|unfollow], [block|unblock]
    # * * [block|unblock]   -- self
    # * * [follow|unfollow] -- other
    # * If will_paginate plugin is installed, then the return Array will be
    # * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def followers *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      user_id ||= self.id
      cache_lookup(user_id, "followers", page, per_page) ||
        TibbrResource.paginate_collection(get(:followers, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), User)
    end

    def announcements *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      user_id ||= self.id
      announcements= TibbrResource.paginate_collection(get(:announcements, :params => {:page=>page, :per_page=>per_page}), Message)
    end

    def subject_announcements *args
      subject_id, page, per_page = TibbrResource.extract_params(args)
      announcements = TibbrResource.paginate_collection(get(:subject_announcements, :params => {:subject_id =>subject_id, :set_actions => true,
            :page=> page, :per_page=>per_page}),Message)
    end

    def global_announcements *args
      subject_id, page, per_page = TibbrResource.extract_params(args)
      user_id ||= self.id
      cache_lookup(user_id, "global_announcements", page, per_page) ||
        TibbrResource.paginate_collection(get(:global_announcements, :params => {:set_actions => true,
            :page=> page, :per_page=>per_page}), Message)
    end

    # Returns an array of Users following the user(with id=user_id).
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # The first argument is user_id, defaults to current user id
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * array of Users. Each object will have an array attribute: 'actions'.
    # * this attribute holds the valid actions on the object by the current user.
    # * * <tt>actions</tt> -- [follow|unfollow], [block|unblock]
    # * * [block|unblock]   -- self
    # * * [follow|unfollow] -- other
    # * If will_paginate plugin is installed, then the return Array will be
    # * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def idols *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      user_id ||= self.id
      cache_lookup(user_id, "idols", page, per_page) ||
        TibbrResource.paginate_collection(get(:idols, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), User)
    end
  
    def idols_subjects *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      init_request
      cache_lookup(user_id, "idols_subjects", page, per_page) ||
        TibbrResource.paginate_collection(get(:idols_subjects, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), User)
    end

    def groups_systems_subjects *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      cache_lookup(user_id, "groups_systems_subjects", page, per_page) ||
        TibbrResource.paginate_collection(get(:groups_systems_subjects, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), User)
    end

    def unsubscribed_broadcast_subjects *args
      user_id, page, per_page = TibbrResource.extract_params(args)
      TibbrResource.paginate_collection(get(:unsubscribed_broadcast_subjects, :params => {:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page}), User)
    end

    # Returns an array of Messages in the inbox of the user(with id=user_id).
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # user_id, defaults to current user id
    # messages_since_id, defaults to nil. When non nil returns the messages sent after the given message id. This is same as :messages_since option
    # ==== Options
    # * <tt>:thread_key</tt>
    # * <tt>:start_after</tt> - gets older messages with sort_id < start_after
    # * <tt>:messages_since</tt> - gets newer messages with sort_id > messages_since. Use this in combination with :start_after for pagination of new messages.
    # * <tt>:message_source_type</tt>
    # * <tt>:message_source_id</tt>
    # * <tt>:message_tags</tt>
    # * <tt>:include_wall_message_types -- eg: application:Rss</tt>
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Messages.
    # * *   Each object will have an array attribute: 'actions'.
    # * * This attribute holds the valid actions on the object by the current user.
    # * * <tt>actions</tt> -- reply
    # * * * * [reply]   -- all
    # * *   Each object will have a User object attribute: 'user'.
    # * * This attribute holds the User object for the Message owner.
    # * *   If will_paginate plugin is installed, then the return Array will be
    # * * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def messages *args
      user_id, messages_since_id, page, per_page, options = TibbrResource.extract_params(args, 4)
      user_id ||= self.id
      read_from_cache = (options[:start_after].nil? and options.blank?)
      options[:messages_since] = messages_since_id if messages_since_id   # with this change, all new_messages requests will only fetch the messages newer than messages_since id
      params = options.merge(:set_actions => true, :user_id => user_id, :page=>page, :per_page=>per_page)
      #We want to get new badge values only when messages are retrieved from server
      ( (read_from_cache ? cache_lookup(user_id, "messages", page, per_page) : nil) ||
          TibbrResource.paginate_collection(get(:messages, :params => params), Message).tap{|msgs| badges(false)}).tap {|msgs|
        msgs.replace(User.messages_since(msgs, messages_since_id.to_i)) unless messages_since_id.nil?}
    end


    def last_10_assets *args
      get(:last_10_assets)
    end
  

    # Returns an array of Messages sent to the subject(with id=subject_id).
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # The first argument is subject_id. The subject_name can also be passed instead of the subject_id.
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Messages.
    # * *   Each object will have an array attribute: 'actions'.
    # * * This attribute holds the valid actions on the object by the current user.
    # * * <tt>actions</tt> -- reply
    # * * * * [reply]   -- all
    # * *   Each object will have a User object attribute: 'user'.
    # * * This attribute holds the User object for the Message owner.
    # * *   If will_paginate plugin is installed, then the return Array will be
    # * * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def subject_messages *args
      subject_id, page, per_page, options = TibbrResource.extract_params(args)
      start_after = options[:start_after]
      TibbrResource.paginate_collection(get(:subject_messages, :params => {:set_actions => true, :subject_id => subject_id, :start_after => start_after, :page=>page, :per_page=>per_page}), Message)
    end

    def private_messages *args
      subject_id, page, per_page, options = TibbrResource.extract_params(args)
      start_after = options[:start_after]
      TibbrResource.paginate_collection(get(:private_messages,
          :params => {:set_actions => true,
            :subject_id => subject_id,
            :start_after => start_after,
            :page=>page,
            :per_page=>per_page}), Message)
    end

    def question_messages *args
      subject_id, page, per_page, options = TibbrResource.extract_params(args)
      start_after = options[:start_after]
      TibbrResource.paginate_collection(get(:question_messages,
          :params => {:set_actions => true,
            :subject_id => subject_id,
            :start_after => start_after,
            :page=>page,
            :per_page=>per_page}), Message)
    end

    def starred_messages *args
      page, per_page, options = TibbrResource.extract_params(args, 2)
      start_after = options[:start_after]
      TibbrResource.paginate_collection(get(:starred_messages,
          :params => {:set_actions => true,
            :start_after => start_after,
            :page=>page,
            :per_page=>per_page}), Message)
    end

    # Returns an array of chat Messages exchanged with other_user (with id=other_user_id).
    # ==== Arguments
    # The first argument is other_user_id
    # ==== Options
    # * <tt>:thread_key</tt> -- optional, will be ignored if not used
    # * <tt>:messages_since</tt> -- optional (timestamp value), will be ignored if not used
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Messages.
    def chat_messages *args
      other_user_id, page, per_page, options = TibbrResource.extract_params(args)
      thread_key = options[:thread_key]
      messages_since = options[:messages_since]
      TibbrResource.paginate_collection(get(:chat_messages,
          :params => {:other_user_id => other_user_id,
            :thread_key => thread_key,
            :messages_since => messages_since,
            :page=>page, :per_page=>per_page}), Message)
    end

    # Posts a message on behalf of the current user. By default the message is sent
    # on users public subject and all other auto tagged subjects.
    # A direct message to an user or a subject can be sent by adding the subject name
    # at the begining of the message. The subject name should be prefixed with a '@'
    # character
    #     u.message("@matt Hello Matt") // sends a direct message to user matt
    #     u.message("@a.b.c Good Morning") // sends a message to the subject 'a.b.c'
    # Returns the Message sent.
    # Throws ActiveResource::ServerError exception on error.
    # usr.message('hi new msg',nil, {:question=>{:multi_select=>true, :allow_others_to_add_options=>true, :question_options=>[{:option_label=>"abc"}]}})
    def message content, parent_id = nil, options = {}
      # assign default values for missing options
      options = options.reverse_merge(:assets => [], :links => [], :geo_location => nil, :question=>nil)
      asset_files = options[:assets]
      resource_params = options[:resources]
      links = options[:links]
      # This line is added for maintaining back compatibility. Need to make following condition more robust
      links= links.map {|link|  {"url" => link} } if links.present? and links.first.class.name == "String"
      geo_location = options[:geo_location]
      question = options[:question]
      calendar = options[:calendar]
      # Throws ActiveResource::ServerError exception on error.
      msg = Message.new
      msg.user_id = id
      msg.content = content
      msg.rich_content = options[:rich_content] unless options[:rich_content].nil?
      msg.parent_id = parent_id
      msg.private_message = options[:is_private]
      msg.assets = []
      msg.links = []
      msg.resources = []
      
      if resource_params.present?
        resource_params.each do|r|
          begin
            resource = Tibbr::Resource.new(r)
            msg.resources << r
          rescue Exception => e
            p "... => ... Error: #{e}"
          end
        end
      end 
      
      if asset_files
        asset_files.each do |asset_file|
          begin
            asset = Tibbr::Asset.new
            asset.data = File.new(asset_file)
            msg.assets << asset
          rescue Exception => e
            p "... => ... Error: #{e}"
          end
        end
      end

      if geo_location
        msg.geo_location = Tibbr::GeoLocation.new(geo_location)
      end

      if links
        links.each do |l|
          if l["url"].present?
            link = Tibbr::Link.new
            link.url = l["url"]
            link.title = l["title"] 
            link.crawler_disable = ((l["crawler_disable"].eql? "true") || (l["crawler_disable"] == true))? l["crawler_disable"] : nil
            msg.links << link
          end
        end
      end

      if calendar
        calendar_options = options[:calendar]
        msg.calendar = Tibbr::Calendar.new(options[:calendar])
      end

      if question   #DARSHAN: Can we put this logic in the question.rb?
        question_options = options[:question].delete(:question_options)
        msg.question = Tibbr::Question.new(options[:question])
        msg.question.question_options = []
        if question_options.present?
          question_options.each do |opt|
            q_opt = Tibbr::QuestionOption.new()
            q_opt.option_label = opt[:option_label]
            q_opt.position = opt[:position] if(opt.has_key?(:position))
            msg.question.question_options << q_opt
          end
        end
      end

      msg.message_source_id = options[:message_source_id]
      msg.message_source_type = options[:message_source_type]
      msg.mtype = options[:mtype] if options[:mtype]
      msg.msg_type = options[:msg_type] if options[:msg_type].present?
      msg.created_at = options[:created_at] if options[:created_at]
      msg.thread_key = options[:thread_key] if options[:thread_key]
      msg.message_tag = options[:message_tag] if options[:message_tag]

      msg.create_with_multipart(asset_files)

      # msg.tap{|msg|}

      Tibbr::Message.update_cache(self, msg) #if cache_lookup(id, "messages")

      msg

      # the code below is not working..
      #      Message.create(options.merge(
      #        :user_id => id,
      #        :content => content,
      #        :parent_id => parent_id,
      #        :assets  => (options[:assets]|| []).map{|data| Tibbr::Asset.new(:data => data)},
      #        :links => (options[:links]|| []).map{|url| Tibbr::Link.new(:url => url)},
      #        :message_source_id => options[:message_source_id],
      #        :message_source_type => options[:message_source_type]
      #      )).tap {|msg| Tibbr::Message.update_cache(self, msg) if msg.errors.blank?}

    end


    # bulk messages does not update the cache. Error details are lost
    def bulk_message messages
      return true if messages.blank?
      Message.post(:bulk_create, {}, messages.to_xml(:root => "messages")).instance_of?(Net::HTTPOK)
    end

    def preferences(options={})
      return @preferences if @preferences
      page = options[:page] || 1
      per_page = options[:per_page] || 999
      group = options[:group_key] || ''
      name = options[:key] || ''
      @preferences = TibbrResource.paginate_collection(get(:preferences, :params => {:group_key => group, :name => name, :page=> page, :per_page=>per_page}),Preference)

    end

    def create_preference(options={})
      group_key = options[:group_key]
      key = options[:key]
      value = options[:value]
      result = post(:create_preference, :user_preference => {:group_key => group_key, :name => key, :value => value})
      @preferences << Tibbr::Preference.new(:group_key => group_key, :name => key, :value => value) if @preferences
      result
    end

    def update_preference(options={})
      group_key = options[:group_key]
      key = options[:key]
      value = options[:value]
      result = put(:update_preference, :user_preference => {:group_key => group_key, :name => key, :value => value})
      if @preferences
        @preferences.each do |pref|
          pref.value = value if(pref.group_key == group_key && pref.name == key)
        end
      end
      result
    end

    def assets(*args)
      page, per_page = TibbrResource.extract_params(args)
      TibbrResource.paginate_collection(get(:assets, :params => {:set_actions => true, :page=> page, :per_page=>per_page}),Asset)
    end
  
    def subject_assets(*args)
      subject_id, page, per_page = TibbrResource.extract_params(args)
      assets = TibbrResource.paginate_collection(get(:subject_assets, :params => {:subject_id =>subject_id, :set_actions => true, :page=> page, :per_page=>per_page}),Asset)
    end
  
    def links(*args)
      page, per_page = TibbrResource.extract_params(args)
      TibbrResource.paginate_collection(get(:links, :params => {:set_actions => true, :page=> page, :per_page=>per_page}),Link)
    end
  
    def subject_links(*args)
      subject_id, page, per_page = TibbrResource.extract_params(args)
      TibbrResource.paginate_collection(get(:subject_links, :params => {:subject_id =>subject_id, :set_actions => true, :page=> page, :per_page=>per_page}),Link)
    end

    def subject_questions(*args)
      subject_id, page, per_page = TibbrResource.extract_params(args)
      TibbrResource.paginate_collection(get(:subject_questions, :params => {:subject_id =>subject_id, :set_actions => true, :page=> page, :per_page=>per_page}),Message)
    end

    # Current user starts following the given user(with id=user_id).
    # Throws ActiveResource::ServerError exception on error.
    def follow user_id
      put(:follow, :params => {:id => user_id}).instance_of?(Net::HTTPOK).tap {|o|
        if o
          cache_remove(self.id, "idols")
          cache_remove(self.id, "followers")
        end
      }
    end

    # Current user stops following the given user(with id=user_id).
    # Throws ActiveResource::ServerError exception on error.
    def unfollow user_id
      put(:unfollow, :params => {:id => user_id}).instance_of?(Net::HTTPOK).tap {|o| 
        if o
          cache_remove(self.id, "idols")
          cache_remove(self.id, "followers")
        end
      }
    end

    # Current user blocks the given user(with id=user_id) from becoming
    # a follower.
    # Throws ActiveResource::ServerError exception on error.
    def block user_id
      put(:block, :params => {:id => user_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Current user allows the given user(with id=user_id) to become
    # a follower.
    # Throws ActiveResource::ServerError exception on error.
    def unblock user_id
      put(:unblock, :params => {:id => user_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Adds the subscription to the given subject(with id=subject_id) for the current user
    # Second parameter is nil by default. This parameter is used for private subjects ONLY.
    # For private subjects only subject owner can add a subscriber. The login_names parameter
    # accepts comma seperated login names as potential subscribers.
    #   u.subscribe(subj.id, "matt,john")
    # Throws ActiveResource::ServerError exception on error.
    def subscribe subject_id, login_names=nil, recommendation_text=nil, group_ids=nil
      put(:subscribe, :params => {:subject_id => subject_id, :login_names => login_names, :group_ids => group_ids,
          :recommendation_text=>recommendation_text}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id, "subscriptions") if o}
    end

    # Removes the subscription to the given subject(with id=subject_id) for the current user
    # Second parameter is nil by default. This parameter is used for private subjects ONLY.
    # For private subjects only subject owner can remove a subscriber.
    #   u.unsubscribe(subj.id, 65)
    # Throws ActiveResource::ServerError exception on error.
    def unsubscribe subject_id, user_id=nil, group_id=nil
      put(:unsubscribe, :params => {:subject_id => subject_id, :user_id => user_id, :group_id => group_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id, "subscriptions") if o}
    end

    # Disables the subscription to the given subject(with id=subject_id) for the current user
    # Throws ActiveResource::ServerError exception on error.
    def pause subject_id
      put(:pause, :params => {:subject_id => subject_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Enables the subscription to the given subject(with id=subject_id) for the current user
    # Throws ActiveResource::ServerError exception on error.
    def play subject_id
      put(:play, :params => {:subject_id => subject_id}).instance_of?(Net::HTTPOK)
    end

    # Pauses the message delivery to the given channel(with id=channel_id) for the current user
    # Throws ActiveResource::ServerError exception on error.
    def channel_pause channel_id
      put(:channel_pause, :params => {:channel_id => channel_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Restarts the message delivery to the given channel(with id=channel_id) for the current user
    # Throws ActiveResource::ServerError exception on error.
    def channel_play channel_id
      put(:channel_play, :params => {:channel_id => channel_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    def channel_activate channel_id, activation_code
      put(:channel_activate, :params => {:channel_id => channel_id, :activation_code => activation_code}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Deletes a channel (with id=subject_id) on behalf of current user
    # Throws ActiveResource::ServerError exception on error.
    def channel_delete channel_id
      put(:channel_delete, :params => {:channel_id => channel_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id, "channels") if o}
      #      temperary fix to handele 404 error.
    rescue Exception => error
      self.populate_error(error)
    end

    # Approves the subscription request to the given subject(with id=subject_id) by the
    # given user (with id=user_id).
    # Current user should be the owner of the subject.
    # Throws ActiveResource::ServerError exception on error.
    def approve subject_id, user_id
      put(:approve, :params => {:subject_id => subject_id, :user_id=>user_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Rejects the subscription request to the given subject(with id=subject_id) by the
    # given user (with id=user_id).
    # Current user should be the owner of the subject.
    # Throws ActiveResource::ServerError exception on error.
    def reject subject_id, user_id
      put(:reject, :params => {:subject_id => subject_id, :user_id=>user_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Returns an array of root Subjects
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    def subject_roots *args
      page, per_page = TibbrResource.extract_params(args, 2)
      TibbrResource.paginate_collection(Subject.get(:roots, :params => {:page=>page, :per_page=>per_page, :user_id=>id, :set_actions => true, :include_inaccessible => true}), Subject)
    end

    # Returns an array of parent Subjects for a given subject
    # Arguments
    # subject_id
    #
    def subject_parents *args
      subject_id, page, per_page = TibbrResource.extract_params(args, 3)
      raise ActiveResource::BadRequest if subject_id.blank?
      TibbrResource.paginate_collection(Subject.new(:id => subject_id).get(:parents, :params => {:page=>page, :per_page=>per_page, :restricted => true, :user_id=>id, :set_actions => true}), Subject)
    end

    # Returns an array of parent Subjects for a given subject
    # Arguments
    # subject_id
    # exclude_descendents: defaults to false
    def subject_children *args
      subject_id, exclude_descendents, page, per_page, options = TibbrResource.extract_params(args, 4)
      raise ActiveResource::BadRequest if subject_id.blank?
      paras = {:page => page, :per_page => per_page, :descendents => (exclude_descendents.nil? ? true : false), :user_id => id, :set_actions => true}
      TibbrResource.paginate_collection(Subject.new(:id => subject_id).get(:children, :params => paras), Subject)
    end

    # Blocks the subscription to the given subject(with id=subject_id) for the
    # given user (with id=user_id).
    # Current user should be the owner of the subject.
    # Throws ActiveResource::ServerError exception on error.
    def subject_block subject_id, user_id
      put(:subject_block, :params => {:subject_id => subject_id, :user_id=>user_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Unblocks the subscription to the given subject(with id=subject_id) for the
    # given user (with id=user_id).
    # Current user should be the owner of the subject.
    # Throws ActiveResource::ServerError exception on error.
    def subject_unblock subject_id, user_id
      put(:subject_unblock, :params => {:subject_id => subject_id, :user_id=>user_id}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Returns an array of Users subscribed to the subject(with id=subject_id).
    # Result set is limited to the data viewable by the current user.
    # ==== Arguments
    # The first argument is subject_id
    # ==== Options
    # Pagination options can be supplied using following parameters
    # * <tt>:page</tt> -- REQUIRED, but defaults to 1 if false or nil
    # * <tt>:per_page</tt> -- defaults to TibbrResource.per_page( which is set to 30)
    # ==== Returns
    # * Array of Subjects. Each object will have an array attribute: 'actions'.
    # * This attribute holds the valid actions on the object by the current user.
    # * <tt>actions</tt> -- [follow|unfollow], [block|unblock], [block_subject|unblock_subject]
    # * * [block|unblock]   -- self
    # * * [follow|unfollow] -- other
    # * * [block_subject|unblock_subject]-- subject owner
    # * If will_paginate plugin is installed, then the return Array will be
    # * of type 'WillPaginate::Collection'
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    #TODO client side validation for subject_id is null
    def subscribers *args
      subject_id, page, per_page,options = TibbrResource.extract_params(args, 3)
      TibbrResource.paginate_collection(get(:subscribers, :params => {:set_actions => true, :subject_id => subject_id, :page=>page, :per_page=>per_page, :order_by => options[:order_by]}), User)
    end

    def subscriber_groups *args
      subject_id, page, per_page = TibbrResource.extract_params(args)
      TibbrResource.paginate_collection(get(:subscriber_groups, :params => {:set_actions => true, :subject_id => subject_id, :page=>page, :per_page=>per_page}), Group)
    end
    # Creates a Subject for the current user using the data given.
    # Returns the created Subject.
    # Throws ActiveResource::ServerError exception on error.
    def subject name, description=nil, scope=:public, parent_id=nil, allow_children=true
      Subject.create(:user_id => self.id, :name => name, :description => description, :scope=>scope, :parent_id=>parent_id, :allow_children => allow_children).tap {|o| cache_remove(self.id, "subjects") if o}
    end

    # Returns the url for the profile image for the user
    # Parameters
    # style = Symbol :small = 24x24, :medium 48x48 = :large  75x75
    # Defaults to :medium
    def profile_image(style=:medium)
      unless defined?(@profile_image_url)
        @profile_image_urls = Hash[*((self.attributes["profile_image_url"] || "").split(","))]
        @profile_image_urls.default = @profile_image_urls[:medium.to_s]
      end
      @profile_image_urls[style.to_s]
    end
    #  def profile_image(options={})
    #    #TODO: This is temp implementation, change this.
    #    options[:size] = :medium #if (options[:size].nil? or [:small, :medium, :large].include?(options[:size]))
    #    return "/images/#{self.login}#{options[:size] == :small ? '_small' : (options[:size] == :medium) ? '' : '_large'}.png"   if ["harish", "matt", "roger", "john"].include?(self.login)
    #    return "/images/default_profile_image.png"
    #  end
  
    # Returns true if the user can view the messages sent on the subject
    # This call works only if the subject has actions array set
    def can_see_subject_messages? subject
      subject.scope == :public or subject.actions.include?(:delete) or !subject.actions.include?(:subscribe)
    end

    # Returns a array of valid actions on the target(User/Message/Subject) object by the current user.
    # Throws ActiveResource::ServerError exception on error.
    def actions_on_message(message_id);actions_on(Message, message_id);end
    def actions_on_user(user_id, subject_id=nil);actions_on(User, user_id, subject_id);end
    def actions_on_subject(subject_id);actions_on(Subject, subject_id);end
    def actions_on_channel(channel_id);actions_on(Channel, channel_id);end
  
    # Returns a array of valid actions on the target object by the current user.
    # Throws ActiveResource::ServerError exception on error.
    def actions_on target_class, target_id, context_id=nil
      raise ActiveResource::BadRequest if target_id.nil? or ![Message, Subject, User, Channel].include?(target_class)
      (get(:actions_on, :params => {:target_class => target_class.name, :target_id => target_id, :context_id=>context_id})["actions"] || "").split(",")
    end

    # Returns a array of privileges on the given target objects for the current user.
    # Parameters:
    # +target_hashes+ => Array of hash objects where each hash contains:
    #   - :target_class => Tibbr::Message
    #   - :target_id => 12
    # 
    # E.g. user.privileges_on([{:target_class => Tibbr::Message, :target_id => 12},
    #                         {:target_class => Tibbr::Subject, :target_id => 23},
    #                         {:target_class => Tibbr::User,    :target_id => 3}])
    #
    # E.g. user.privileges_on([{:target_class => Tibbr::Subject, :target_id => 15}])
    # 
    # E.g. user.privileges_on([{:target_class => Tibbr::Subject}])
    #
    # Returns: an array of hash objects where each hash contains:
    #   - :target_class => Tibbr::Message
    #   - :target_id => 12
    #   - :privileges => ['read','delete']
    #
    # Throws ActiveResource::BadRequest or ActiveResource::UnauthorizedAccess exception on error.
    def privileges(target_hashes = [])
      valid_classes = [Tibbr::User, Tibbr::Message, Tibbr::Subject, Tibbr::Channel,
        Tibbr::Schedule, Tibbr::SubscriptionRequest, Tibbr::MessageFilter,
        Tibbr::ApplicationInstance, Tibbr::ApplicationDefinition, Tibbr::Role, Tibbr::BannedWord, Tibbr::Community, Tibbr::Group]
      raise ActiveResource::BadRequest if target_hashes.any? {|target_hash| !valid_classes.include?(target_hash[:target_class])}
      target_objects = []
      target_hashes.each{|target_hash| target_objects << {}.tap{|h|
          h[:target_class] = target_hash[:target_class].name
          h[:target_id] = target_hash[:target_id]}}
      format_privileges((get(:privileges_on, :params => {:target_objects => target_objects}) || {})["privileges_array"])
    end

    attr_accessor :badges
    # Returns a hash of badges for the current user.
    # E.g. user.badges[:unread]
    #
    # E.g. user.badges[:private_unread]
    #
    # Returns: a hash:
    #   - :unread => 5
    #   - :private_unread => 3
    #
    def badges(from_cache=true)
      (@badges ||= (from_cache ? {} : ((get(:badges) || {})["badges"] || {})).symbolize_keys) rescue {}
    end

    # Parameters
    # schedules = Optional. Comma seperated generic schedule names.
    # subject_schedules = Array of hash
    #     subject_id
    #     schedules = Optional. Comma seperated subject schedule names.
    # template =  Optional. Name of the template to use for generation of schedules. When not supplied server uses the default template
    #
    # The schedule names supplied in the paremeters should match the schedule names configured at the server for the given template.
    #
    # Returns true upon success
    # Example
    # u.build_templated_channel_schedules(ch.id, "day,night", [{:subject_id=>2, :schedules=>"realtime,weekend"}])
    # u.build_templated_channel_schedules(ch.id, "common")
    #
    def build_templated_channel_schedules channel_id, schedules, subject_schedules, template=nil
      #      include params in the body as it could be long
      put(:build_templated_channel_schedules, {}, {:channel_id => channel_id, :schedules => schedules, :subject_schedules => subject_schedules, :template=>(template||"")}.to_xml(:root => 'params').to_s).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # Example
    # u.update_subject_channel_schedules(channel, [{:subject_id=>2, :schedules=>"realtime"}])
    # u.update_subject_channel_schedules(channel, [{:subject_id=>2, :schedules=>""}]) Pass "" parameter to reset the schedule
    def update_subject_channel_schedules channel, subject_schedules
      (channel.update_subject_channel_schedules subject_schedules).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    # returns a hash
    # {
    #   schedules   => Comma seperated generic schedule names.
    #   subject_schedules =>  Array of hash
    #     subject_id
    #     schedules = Comma seperated subject schedule names.
    # }
    def templated_channel_schedules channel_id
      get(:templated_channel_schedules, :params => {:channel_id => channel_id})
    end

    #emails = Array email addresses e.g. ['user1@email.com','user2@email.com','user3@email.com'].
    #invitation_message = String containing the personal message which is to be sent with the invitation.
    def invite_to_join emails=[], invitation_message=''
      post(:invite_to_join, :params => {:emails => emails, :invitation_message => invitation_message}).instance_of?(Net::HTTPOK)
    end

    # user_ids = Array of user_id's. Send the recommendation to these user ids
    # subject_id = the recommended subject id
    def recommend_a_subject user_ids, subject_id, emails, group_ids = nil, recommendation_text=''
      post(:recommend_a_subject, :params => {:user_ids => user_ids, :subject_id => subject_id,:emails=>emails, :group_ids => group_ids,
          :recommendation_text => recommendation_text}).instance_of?(Net::HTTPOK)
    end


    # user_ids = Array of user_id's. Send the recommendation to these user ids
    # message_id = the recommended message id
    def share_a_message user_ids, message_id, group_id,  recommendation_text=''
      post(:share_message, :params => {:user_ids => user_ids.join(","), :group_ids=>group_id, :message_id => message_id, :recommendation_text => recommendation_text}).instance_of?(Net::HTTPOK)
    end

    # Parameters
    # password = Current password.
    # new_password = New password.
    # new_password_confirmation = New password confirmation.
    #
    # Returns true upon success
    # Example
    #
    def change_password password, new_password, new_password_confirmation
      put(:change_password, :params => {:password => password, :new_password => new_password, :new_password_confirmation => new_password_confirmation}).instance_of?(Net::HTTPOK).tap {|o| cache_remove(self.id) if o}
    end

    def viewer_id
      self.attributes['viewer_id']
    end
  
    def v_page
      self.attributes['v_page']
    end
  
    def v_per_page
      self.attributes['v_per_page']
    end

    def v_last_broadcast_message_id
      self.attributes['v_last_broadcast_message_id'] || 0
    end

    def cached?
      self.attributes['cached'] == true
    end
  
    #    def custom_properties
    #      @custom_properties ||= (self.attributes['custom_properties'].attributes rescue nil) || (self.custom_properties = {})
    #    end

    #    def save
    #      # we have to ensure a hash is sent to the server
    #      #self.custom_properties = custom_properties
    #      super
    #    end

    # This API will be used when default system filters will be implemented.
    def get_default_homepage
      return []   #this API is current not in use but looks like its tightly coupled in the webclient code
      @filter = get(:get_default_system_filter)
      home_messages = self.message_search({:message_filter_id=>@filter["system_filter"]["pref_value"] }) if @filter["system_filter"]["pref_type"] == "system"
      #home_messages = self.message_search({:message_filter_id=>""}) if @filter["system_filter"]["pref_type"] == "API" && @filter["system_filter"]["pref_value"] == "all"
      return [@filter["system_filter"]["pref_type"], @filter["system_filter"]["pref_value"], @filter["system_filter"]["pref_label"], home_messages]
    end

    def set_log_level *args
      get(:set_log_level, :params => args.extract_options!).instance_of?(Net::HTTPOK)
    end

    def register_device(device_token)
      put(:register_device, :params => {:device_type => 'webclient', :device_token => device_token}).instance_of?(Net::HTTPOK)
    end

    def user_activities
      @user_activities ||= get(:user_activities)
    end

    def follower_requests *args
      page, per_page = TibbrResource.extract_params(args, 2)
      TibbrResource.paginate_collection(get(:follower_requests, :params => {:page=>page, :per_page=>per_page}), FollowerRequest)
    end

    # Current user starts following the given user(with follower_id=follower_id).
    # Throws ActiveResource::ServerError exception on error.
    def accept_follower_request follower_id
      put(:accept_follower_request, :params => {:follower_id => follower_id}).instance_of?(Net::HTTPOK).tap {|o|
        if o
          cache_remove(self.id, "idols")
          cache_remove(self.id, "followers")
        end
      }
    end

    # Current user starts following the given user(with follower_id=follower_id).
    # Throws ActiveResource::ServerError exception on error.
    def reject_follower_request follower_id
      put(:reject_follower_request, :params => {:follower_id => follower_id}).instance_of?(Net::HTTPOK).tap {|o|
        if o
          cache_remove(self.id, "idols")
          cache_remove(self.id, "followers")
        end
      }
    end
    
    protected
    def init_request
      #    user = (login || "harish")
      #    password = "test"
    end

    #user_hash_array = Array of user hash objects (root users in the subtree)
    #Returns: Array of User objects (root users in the subtree)
    def self.users_with_hierarchy user_hash_array
      user_hash_array.map {|user_hash| user_with_hierarchy user_hash }
    end

    def self.user_with_hierarchy user_hash
      User.new.tap do |u|
        u.children = users_with_hierarchy(user_hash.delete('children')) if user_hash.has_key?('children')
        u.load(user_hash)
      end
    end

    def obj_lookup(user_id, name=nil, page=1, per_page=TibbrResource.per_page)
      user = get_user(user_id)
      return nil unless (!user.nil? and user.class == Tibbr::User and !user.cached? and user.viewer_id == self.id)
      return user if name.nil?
      list = user.attributes[name]
      return nil if list.nil?
      if (name == "messages" and user.broadcast == true)
        msgs = Tibbr::User.broadcast_msg_since(user.v_last_broadcast_message_id)
        unless msgs.empty?
          user.cache_add(msgs, nil, name)
          user.attributes[name] = list = User.cache_lookup(user.cache_key, name, page, per_page)
        end
      end
      (user.v_page == page and user.v_per_page >= per_page and list)
    end

    def get_user user_para
      return user_para if user_para.class == Tibbr::User
      return self if user_para.nil? or user_para.to_i == self.id
    end
  
    def get_user_id user_para
      return self.id if user_para.nil?
      return user_para.id if user_para.class == Tibbr::User
      return user_para.to_i
    end
  
    def comma_seperated_ids ids
      return ids if ids.nil?
      return ids if ids.is_a?(String)
      return ids.id if ids.is_a?(ActiveResource::Base)
      return "" unless ids.is_a?(Array)
      ids.all?{|v| v.is_a?(Fixnum) or v.is_a?(String)} ? ids.join(",") : (ids.all?{|v| v.is_a?(ActiveResource::Base)} ? ids.collect(&:id).join(",") : "")
    end

    def subject_channel_action action, subject_id, channels
      channel_ids = comma_seperated_ids(channels)
      #    return false if channel_ids.blank?
      subject_id = subject_id.id if subject_id.is_a?(ActiveResource::Base)
      put("subject_channels_#{action}".to_sym, :params => {:channel_ids => channel_ids, :subject_id => subject_id}).instance_of?(Net::HTTPOK)
    end

    def disable
      put(:disable).instance_of?(Net::HTTPOK)
    end

    def enable
      put(:enable).instance_of?(Net::HTTPOK)
    end

    def format_privileges(privileges_array)
      (privileges_array || []).each{|target_obj|
        target_obj.symbolize_keys!
        target_obj[:target_class] = "Tibbr::#{target_obj[:target_class]}" unless target_obj[:target_class].starts_with?('Tibbr::')
        target_obj[:target_class] = target_obj[:target_class].constantize unless target_obj[:target_class].blank?
        target_obj[:target_id] = target_obj[:target_id].to_i unless target_obj[:target_id].blank?
        target_obj[:privileges] = (target_obj[:privileges] || "").split(',')
      }
    end

    #TODO: put these methods in a generic location so that they can be used at other places in tibbr-api
    #NOTE: These methods provide support for instance level caching.
    def inst_cache_lookup var_name, paginated = false, page = 1, per_page = TibbrResource.per_page
      inst_cache_hit = (paginated) ? (inst_paginated_collection_lookup(inst_cache_get(var_name), page, per_page)) : inst_cache_get(var_name)
      (inst_cache_hit.nil? and block_given?) ? inst_cache_set(var_name, yield) : inst_cache_hit
    end

    def inst_cache_remove(var_name)
      inst_cache_set(var_name, nil)
    end

    def inst_cache_set(var_name, list = nil)
      self.instance_variable_set(var_name, list)
    end

    def inst_cache_get(var_name)
      self.instance_variable_get(var_name)
    end

    def inst_paginated_collection_lookup collection, page = 1, per_page = TibbrResource.per_page
      (collection.nil? or collection.current_page != page or collection.per_page < per_page) ? nil :
        (collection[((page-1)*per_page)...(page*per_page)]).paginate(:page => page, :per_page => per_page, :total_entries => collection.total_entries)
    end

  end

end
