module Tibbr
  class Group < TibbrResource
    attr_accessor :public_subject, :private_subject, :members, :owners, :actions
    
    def add_members(member_ids)
      put(:add_members, :params =>{:member_ids => member_ids })
    end

    def remove_members(member_ids)
      put(:remove_members, :params =>{:member_ids => member_ids })
    end
    # Current user starts following the given Group(with id=user_id).
    # Throws ActiveResource::ServerError exception on error.
    def follow
      put(:follow).instance_of?(Net::HTTPOK)
    end

    def unfollow
      put(:unfollow).instance_of?(Net::HTTPOK)
    end

    def initialize(object_hash = {})
      self.members ||= object_hash["members"].present? ? TibbrResource.paginate_collection(object_hash.delete("members"), User): []
      self.owners ||= object_hash["owners"].present? ? TibbrResource.paginate_collection(object_hash.delete("owners"), User) : []
      self.private_subject ||= object_hash["private_subject"].present? ? Subject.new(object_hash.delete("private_subject")) : nil
      self.public_subject ||= object_hash["public_subject"].present? ? Subject.new(object_hash.delete("public_subject")) : nil
      self.actions ||= object_hash["actions"].present? ? object_hash.delete("actions").split(",").map{|a| a.strip} : []
      super
    end

    def load attributes
      self.members = TibbrResource.paginate_collection(attributes.delete("members"), User) if attributes["members"]
      self.owners = TibbrResource.paginate_collection(attributes.delete("owners"), User) if attributes["owners"]
      self.private_subject = Subject.new(attributes.delete("private_subject")) if attributes["private_subject"]
      self.public_subject = Subject.new(attributes.delete("public_subject")) if attributes["public_subject"]
      self.actions = attributes.delete("actions").split(",").map{|a| a.strip} if attributes["actions"]
      super
    end

    # Update the resource on the remote service.
    def update
      multipart? ? multipart_send(update_url,:put) : super
      return errors.empty?
    end

    # Create (i.e., \save to the remote service) the \new resource.
    def create
      (multipart? ? multipart_send(create_url,:post) : super).instance_of?(Net::HTTPCreated)
    end

    def meta_details(reload=false)
      self.class.get(:meta_details).map{|opt| Tibbr::MetaInfo.new(opt)}.sort_by{|m| m.position.try(:to_f)}
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

    def self.find_by_subject_id sub_id
      grp_hash = get(:find_by_subject_id, :params => {:subject_id=> sub_id})
      Group.new(grp_hash)
    end

    def owner_list *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      user_id ||= self.id
      TibbrResource.paginate_collection(get(:owners, :params => { :page=>page, :per_page=>per_page}), User)
    end
	
	def member_list *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      user_id ||= self.id
      TibbrResource.paginate_collection(get(:members, :params => { :page=>page, :per_page=>per_page}), User)
    end
	
	def follower_list *args
      user_id, page, per_page = TibbrResource.extract_params(args, 3)
      user_id ||= self.id
      TibbrResource.paginate_collection(get(:followers, :params => { :page=>page, :per_page=>per_page}), User)
    end

    def assign_owners user_list=[]
      post(:assign_owners, :params=>{:users=>user_list.join(",")}).instance_of?(Net::HTTPOK)
    end


  end
end