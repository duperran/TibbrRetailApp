module Tibbr

  class Message < TibbrResource

    def subjects
      @subjects = self.attributes["subjects"] || []
    end

    def messages
      @messages = self.attributes["messages"] || []
    end
  
    def links
      @links = self.attributes["links"] || []
      return @links if @link_parent_established
      @links.each {|l| l.owner= self}
      @link_parent_established = true
      @links
    end
    
    def assets
      @assets = self.attributes["assets"] || []
    end

    def geo_location
      @geo_location = self.attributes["geo_location"]
    end

    def private_message
      @private_message= self.attributes["private_message"]
    end

    def like_to
       @like_to = self.attributes["like_to"] || []
    end

    def question
      @question = self.attributes["question"]
    end

    def calendar
      @calendar = self.attributes["calendar"]
    end

    alias :replies :messages

    #    def create
    #      result = multipart? ? multipart_send(create_url,:post) : super
    #      return false unless result
    #
    #      #super #.tap{|r| Tibbr::Message.update_cache(self)}
    #    end

    def set_announcement(options = {})
      put(:set_announcement, :announcement => options)
    end

    def delete_announcement(options = {})
      http_delete(:delete_announcement, :announcement => options)
    end

    # Usage Examples:
    # @message.add_subjects([@sub1, @sub2], :user => current_user)
    # @message.add_subjects([164, 300], :user => current_user)
    # passing the current_user is necessary to avoid caching issues.
    def add_subjects(subjects, options = {})
      subjects = Array(subjects)
      subject_ids = case subjects.first
      when Integer,String then subjects.join(",")
      when Tibbr::Subject then subjects.collect{|sub| sub.id}.join(",")
      else raise ActiveResource::BadRequest
      end
      user = options.delete(:user)
      load_from_response(put(:add_subjects, :params => {:subject_ids => subject_ids})).tap {|res|
        Tibbr::User.cache_remove(user.cache_key) if(res and user)} # clear the user cache if message updated
    end

    #FIXME: updating the users cache with the like operation requires the users object.
    #Currently there is no way to access the current_user in the tibbr_api
    #hence passing it from calling method.
    def like(options = {})
      user = options.delete(:user)
      put(:like, :like => options).tap{|res|
        if (user and res.instance_of?(Net::HTTPOK))
          #TODO: Following line is adding a very large current_user object in the users cache too many times.
          self.attributes["like_to"] = self.attributes["like_to"] + [user]
          self.attributes["actions"] =  (self.actions.delete_if {|action| action == "like" } << "unlike").join(", ")
          Tibbr::Message.update_cache(user, self, {:only_update_if_exists => true})
        end
      }
    end

    def unlike(options = {})
      user = options.delete(:user)
      http_delete(:unlike, :like => options).tap{|res|
        if (user and res.instance_of?(Net::HTTPOK))
          self.attributes["like_to"] = self.attributes["like_to"].delete_if{|usr| usr.id == user.id}
          self.attributes["actions"] = (self.actions.delete_if {|action| action == "unlike" } << "like").join(", ")
          Tibbr::Message.update_cache(user, self, {:only_update_if_exists => true})
        end
      }
    end

    def star(options = {})
      user = options.delete(:user)
      put(:star).tap{|res|
        if (user and res.instance_of?(Net::HTTPOK))
          self.attributes["actions"] =  (self.actions.delete_if {|action| action == "star" } << "unstar").join(", ")
          Tibbr::Message.update_cache(user, self, {:only_update_if_exists => true})
        end
      }
    end

    def unstar(options = {})
      user = options.delete(:user)
      put(:unstar).tap{|res|
        if (user and res.instance_of?(Net::HTTPOK))
          self.attributes["actions"] =  (self.actions.delete_if {|action| action == "unstar" } << "star").join(", ")
          Tibbr::Message.update_cache(user, self, {:only_update_if_exists => true})
        end
      }
    end

    #    def like_to(options = {})
    #      get(:like_to, :like => options)
    #    end

    # creates a conference message
    # Parameters:
    # conf_type = :video or :webinar or :audio
    # agenda = 'conference agenda text'
    # users = Array of users or user_ids or user_logins
    # subjects = Array of subjects or subject_ids or subject_names
    # emails  = Array of email address
    def self.create_conference(conf_type = :video, agenda = '', users = [], subjects = [], emails = [])
      raise ActiveResource::BadRequest if((users.present? and !users.is_a?(Array)) or (subjects.present? and !subjects.is_a?(Array)))
      raise ActiveResource::BadRequest if(users.blank? and subjects.blank? and emails.blank?)
      users = users.collect{|user| (user.is_a?(String) or user.is_a?(Integer)) ? user.to_s : user.id}.join(',')
      subjects = subjects.collect{|subject| (subject.is_a?(String) or subject.is_a?(Integer)) ? subject.to_s : subject.id}.join(',')
      res = post(:create_conference, :params => {:conf_type => conf_type, :agenda => agenda, :users => users, :subjects => subjects, :emails => emails})
      conference = format.decode(res.body)
      conference = conference.with_indifferent_access if conference.is_a?(Hash)
      conference[:presenter][:message] = Tibbr::Message.new(conference[:presenter][:message]) unless conference.try("[]", :presenter).try("[]", :message).blank?
      conference[:participant][:message] = Tibbr::Message.new(conference[:participant][:message]) unless conference.try("[]", :participant).try("[]", :message).blank?
      conference
    end

    # Creates an end conference message with the recorded conference url
    # Parameters:
    # message_id = id of the conference participant message
    # recorded = true/false if the conference is recorded
    def self.end_conference(message_id, recorded = false)
      res = post(:end_conference, :params => {:message_id => message_id, :recorded => recorded.to_bool})
      conference = format.decode(res.body)
      conference = conference.with_indifferent_access if conference.is_a?(Hash)
      conference[:participant][:message] = Tibbr::Message.new(conference[:participant][:message]) unless conference.try("[]", :participant).try("[]", :message).blank?
      conference
    end
    
    def create_with_multipart(asset_files)
      multipart? ? multipart_send(create_url, :post) : save
      asset_files.each do |asset_file|
        FileUtils.rm_rf(File.dirname(asset_file)) if File.exists?(File.dirname(asset_file))
      end if asset_files
    rescue Exception => e
      p "... => Error: #{e.inspect}\n#{e.backtrace}"
    end

    def update
      super #.tap{|r| Tibbr::Message.update_cache(self)}
    end

    def delete
      #TODO: verify the effects of load_from_response on the message object, since it may contain assets etc.
      #currently (2.0 milestone) we do not have any scenario which would be affected by this.
      load_from_response(put(:delete))
    end

    def undelete
      load_from_response(put(:undelete))
    end

    def mute
      put(:mute).instance_of?(Net::HTTPOK)
    end

    def unmute
      put(:unmute).instance_of?(Net::HTTPOK)
    end

    def self.update_cache user, message, options={}
      return unless message.valid?
      if message.broadcast
        Tibbr::User.cache_add_broadcast_msg(message)
        Tibbr::User.cache_add(user.cache_key, message, "messages", 1, options)
      else
        Tibbr::User.cache_add(user.cache_key, message, "messages", 1, options)
      end
    rescue Exception => e
      # log the error
      Rails.logger.warn("Error while updating the message cache: #{e.inspect}\n#{e.backtrace}")
    end

    def self.cache_remove user, message=nil
      return if user.nil?
      Tibbr::User.cache_remove(user.cache_key, 'messages', message)
    end

    def self.search(options = {})
      TibbrResource.paginate_collection(get(:index, options), Tibbr::Message)
    end

  end
end