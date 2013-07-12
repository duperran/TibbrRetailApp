module Tibbr
  
  class ContextProperties < TibbrResource
    def [](key)
      attributes[key]
    end
  end

  class Subject < TibbrResource
    def last_message
      attributes['message']
    end
    attr_accessor :owners, :children
    # Returns the url for the subject image for the subject
    # Parameters
    # style = Symbol :small = 24x24, :medium 48x48 = :large  75x75
    # Defaults to :medium
    def subject_image(style=:medium)
      unless defined?(@subject_image_url)
        @subject_image_urls = Hash[*((self.attributes["subject_image_url"] || "").split(","))]
        @subject_image_urls.default = @subject_image_urls[:medium.to_s]
      end
      @subject_image_urls[style.to_s]
    end

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
      multipart? ? multipart_send(create_url,:post) : super
      self.id = Subject.find_by_name(self.name).id if self.valid?
      self.valid?
    end

    def self.find_by_name name
      Subject.new(get(:find_by_name, :params => {:name => name, :set_actions => true}))
    rescue ActiveResource::ConnectionError => error
      Subject.new.tap{|s| s.populate_error(error)}
    end

    def multi_part?
      attributes.any?{|k, v| v.respond_to?(:read) and v.respond_to?(:path) }
    end

    # Returns array of Subjects.
    # ==== Arguments
    # The first argument is created_after. Default is 15.days.ago.
    # ==== Returns
    # * Array of Subject object. Each object in the array will have an array attribute: 'actions'.
    # * This attribute holds the valid actions on the object by the current user.
    # * <tt>actions</tt> -- [subscribe|unsubscribe], [pause|play], [delete]
    # * * [block|unblock]   -- self
    # * * [follow|unfollow] -- other
    # * * [delete]          -- owner
    # ==== Throws
    # +ActiveResource::ServerError+ exception on error.
    def self.recent_subjects *args
      page, per_page, options = TibbrResource.extract_params(args,2)
      recent_subs = [].paginate(:per_page => per_page)
      if(options[:start_after].blank?)
        TibbrResource.tcache.fetch("recent_subjects", :force => options[:set_actions], :expires_in => 10.minutes) do
          TibbrResource.paginate_collection((get(:recent_subjects, :params => {:page => page, :per_page => per_page})), Subject)
        end.tap {|collection| recent_subs = collection[((page-1)*per_page)...(page*per_page)].paginate(:page => page,
            :per_page => per_page, :total_entries => collection.total_entries)}
        return recent_subs
      else
        TibbrResource.paginate_collection((get(:recent_subjects, :params =>
                {:page => page, :per_page => per_page, :start_after=>options[:start_after]})), Subject)
      end
    end

    def delete_all_announcements
      delete(:delete_all_announcements)
    end

    def set_announcement(message_id)
      put(:set_announcement, :params => {:message_id => message_id})
    end

    def delete_announcement(message_id)
      delete(:delete_announcement, :params => {:message_id => message_id})
    end

    def user_private?
      self.stype == "system" and self.scope == "private"
    end

    def delete
      load_from_response(put(:delete)).tap{|status| TibbrResource.tcache.delete("recent_subjects") if status}
    end

    def undelete
      load_from_response(put(:undelete)).tap{|status| TibbrResource.tcache.delete("recent_subjects") if status}
    end

    #def initialize(object_hash = {})
    #  @owners= object_hash["owners"].present? ? TibbrResource.simple_collection(object_hash.delete("owners"), User): []
    #  @children = object_hash.has_key?("children") ? Subject.subjects_with_hierarchy(object_hash.delete("children")) : nil
    #  super
    #end

    #Returns: Subject (root subject in the tree along with hierarchy upto this subject + one level down)
    def ancestry_tree
      Subject.new(get(:ancestry_tree, :params => {:set_actions => true}))
    end

    def my_pages( *args)
      page, per_page = TibbrResource.extract_params(args,2)
      TibbrResource.paginate_collection((get(:my_pages, :params =>
                {:page => page, :per_page => per_page})), Page)
    end
    #subject_hash_array = Array of user hash objects (root subjects in the subtree)
    #Returns: Array of Subject objects (root subjects in the subtree)
    def self.subjects_with_hierarchy subject_hash_array
      subject_hash_array.map {|subject_hash| Subject.new(subject_hash) }
    end
  end
end