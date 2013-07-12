module Tibbr
  class Role < TibbrResource

    # attributes =>
    #   :rolename => unique type of the role. E.g. 'admin', 'subject_owner', 'feeds_manager'
    #   :display_name => title for the role. E.g. 'Administrator', 'Subject Owner', 'Feeds Manager'

    #Create Role
    #role = Tibbr::Role.create(:rolename => 'subject_creator', :display_name => 'Subject Creator')
    #
    #Find a role
    #role = Tibbr::Role.find(9)
    #
    #Get all roles (non-context-specific roles only)
    #roles = Role.find(:all)

    module RoleName
      ADMINISTRATOR = "admin"
      USER = "user"
      SUBJECT_OWNER = "subject_owner"
      APPLICATION_DEFINITION_USER = "app_def_user"
      APPLICATION_DEFINITION_SUBSCRIBER = "app_def_subscriber"
      COMMUNITY_USERS = "community_users"
      GROUP_OWNER = "group_owner"
      SUBJECT_READER = "subject_reader"
      GUEST = "guest"
      TENANT_MANAGER = "tenant_manager"
    end

    MEMBERS = "@members"
    GROUPS = "@groups"
    PRIVILEGES = "@privileges"
    def initialize(object_hash = {})
      self.instance_variable_set(MEMBERS, (object_hash.has_key?("members") ? TibbrResource.paginate_collection(object_hash.delete("members"), User): nil))
      self.instance_variable_set(GROUPS, (object_hash.has_key?("groups") ? TibbrResource.paginate_collection(object_hash.delete("groups"), Group): nil))
      self.instance_variable_set(PRIVILEGES, (object_hash.has_key?("privileges") ? format_privileges(object_hash.delete("privileges")): nil))
      super
    end

    #NOTE: overriding default ActiveResource.find method for introducing default params into it
    def self.find(*args)
      opts = args.extract_options!
      opts[:params] ||= {}
      opts[:params][:params] ||= {}
      opts[:params][:params][:include_members] ||= true
      opts[:params][:params][:include_privileges] ||= true
      args << opts
      super
    end

    #Tibbr::Role.find_by_rolename_and_context('subject_owner', @subject)
    #Tibbr::Role.find_by_rolename_and_context('subject_owner')
    def self.find_by_rolename_and_context(rolename, role_context = nil)
      Role.new(get(:find_by_rolename_and_context, :params => {:rolename => rolename, 
            :context_type => (role_context.nil? ? nil : role_context.class.name),
            :context_id => (role_context.nil? ? nil : role_context.id),
            :include_members => true, :include_privileges => true}))
    rescue ActiveResource::ResourceInvalid => error
      Role.new.tap{|r| r.populate_error(error)}
    end

    # E.g. users = role.members
    def members *args
      page, per_page, options = TibbrResource.extract_params(args, 2)
      cache_lookup(MEMBERS, true, page, per_page) do
        TibbrResource.paginate_collection(get(:members, :params => {:include_group_members => options[:include_group_members], :page => page, :per_page => per_page}), User)
      end
    end

    def groups *args
      page, per_page = TibbrResource.extract_params(args, 2)
      cache_lookup(GROUPS, true, page, per_page) do
        TibbrResource.paginate_collection(get(:groups, :params => {:page => page, :per_page => per_page}), Group)
      end
    end

    # E.g. role.add_members(user_ids=[1,2,3,4], group_ids=[])
    def add_members(user_ids=nil,group_ids=[])
      user_ids=[] if user_ids.blank?
      user_ids.uniq!
      put(:add_members, :params => {:user_ids => user_ids.join(','), :group_ids => group_ids.join(',')}).instance_of?(Net::HTTPOK).tap{|status| cache_remove(MEMBERS) if status}
    end

    # E.g. role.remove_members([1,2,3,4])
    def remove_members(user_ids = [], group_ids=[])
      put(:remove_members, :params => {:user_ids => user_ids.join(','), :group_ids => group_ids.join(',')}).instance_of?(Net::HTTPOK).tap{|status| cache_remove(MEMBERS) if status}
    end


    # Returns a array of privileges to the current role.
    # E.g. role.privileges
    #
    # Returns: an array of hash objects where each hash contains:
    #   - :target_class => Tibbr::Message
    #   - :privileges => ['read','delete']
    #
    # Throws ActiveResource::BadRequest or ActiveResource::UnauthorizedAccess exception on error.
    def privileges
      cache_lookup(PRIVILEGES) { format_privileges(get(:privileges)["privileges"]) }
    end

    # Assigns an array of privileges to the current role.
    # Parameters:
    # +privileges_array+ => can be any number of hash objects where each hash contains:
    #   - :target_class => Tibbr::Subject
    #   - :privilege => 'create'
    #
    # E.g. role.overwrite_privileges([{:target_class => Tibbr::Subject, :privilege => 'manage'},
    #                         {:target_class => Tibbr::User, :privilege => 'manage'},
    #                         {:target_class => Tibbr::Subject, :privilege => 'create'}])
    #
    # E.g. role.overwrite_privileges([{:target_class => Tibbr::Subject, :privilege => 'manage'}])
    #
    def overwrite_privileges(privileges = [])
      valid_classes = [Tibbr::User, Tibbr::Subject, Tibbr::Role, Tibbr::ApplicationDefinition, Tibbr::ApplicationInstance, Tibbr::BannedWord, Tibbr::Community, Tibbr::Group]
      raise ActiveResource::BadRequest if privileges.any? {|target_hash| !valid_classes.include?(target_hash[:target_class])}
      privileges_array = []
      privileges.each{|privilege_hash| privileges_array << {}.tap{|h|
          h[:target_class] = privilege_hash[:target_class].name
          h[:privilege] = privilege_hash[:privilege]}}
      put(:overwrite_privileges, :params => {:privileges_array => privileges_array}).instance_of?(Net::HTTPOK).tap{|status| cache_remove(PRIVILEGES) if status}
    end

    def delete
      load_from_response(put(:delete))
    end

    def undelete
      load_from_response(put(:undelete))
    end

    protected

    def format_privileges(privilege_objects)
      (privilege_objects ||= []).each do |privilege_obj|
        privilege_obj.symbolize_keys!
        privilege_obj[:target_class] = "Tibbr::#{privilege_obj[:target_class]}".constantize
        privilege_obj[:privilege] = privilege_obj[:privilege]   #noop?
      end
    end

    #TODO: put these methods in a generic location so that they can be used at other places in tibbr-api
    #NOTE: These methods provide support for instance level caching.
    def cache_lookup var_name, paginated = false, page = 1, per_page = TibbrResource.per_page
      cache_hit = (paginated) ? (paginated_collection_lookup(cache_get(var_name), page, per_page)) : cache_get(var_name)
      (cache_hit.nil? and block_given?) ? cache_set(var_name, yield) : cache_hit
    end

    def cache_remove(var_name)
      cache_set(var_name, nil)
    end

    def cache_set(var_name, list = nil)
      self.instance_variable_set(var_name, list)
    end

    def cache_get(var_name)
      self.instance_variable_get(var_name)
    end

    def paginated_collection_lookup collection, page = 1, per_page = TibbrResource.per_page
      (collection.nil? or collection.current_page != page or collection.per_page < per_page) ? nil :
        (collection[((page-1)*per_page)...(page*per_page)]).paginate(:page => page, :per_page => per_page, :total_entries => collection.total_entries)
    end

  end
end