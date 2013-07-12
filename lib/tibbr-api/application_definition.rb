module Tibbr
  class ApplicationDefinition < TibbrResource
    # all(:include_deleted => true)   - will return all application_definitions including the deleted ones.
    # all(:include_deleted => false)  - will return all application_definitions excluding the deleted ones.
    # all()                           - will return all application_definitions excluding the deleted ones.
    #def self.find app_id
    #  opts = args.extract_options!
      #opts[:params] ||= {}
      #opts[:params][:params] ||= {}
      #opts[:params][:params][:set_actions] ||= "true"
      #opts[:params][:params][:profile] = "complete" if opts[:profile].to_s == "complete"
    #  args << opts
    #  super
    #end

    def self.all(options = {})
      find(:all, :params => (options || {}).slice(:include_deleted, :page, :per_page))
    end

    def delete
      load_from_response(put(:delete))
    end

    def undelete
      load_from_response(put(:undelete))
    end

    def subscribe
      load_from_response(put(:subscribe))
    end

    def unsubscribe
      load_from_response(put(:unsubscribe))
    end

    def subscribers
      load_from_response(get(:subscribers)) 
    end
    
    def old_versions
      attributes["old_versions"] || []
    end

    def add_assets(assets)
      self.attributes["assets"] ||= []
      if assets.present?
        assets.each do |a|
          asset = Tibbr::Asset.new
          asset.data = a['data']
          self.attributes["assets"] << asset
        end
      end
    end
    
    def set_categories(params)
      deleted_categories = []
      params.map! {|param| param.to_i}
      self.attributes["application_definition_categories"] = [] if self.attributes["application_definition_categories"].blank?
      self.attributes["application_definition_categories"].delete_if {|category| 
         (deleted_categories << category unless params.include? category.attributes["category_id"]) 
        params.delete_if {|param| param == category.attributes["category_id"]}
        !params.include? category.attributes["category_id"]}
      self.attributes["application_definition_categories"].concat deleted_categories.map {|category| category.tap {|c| category.attributes[:should_destroy] = true}}
      
      params.collect { |c| self.attributes["application_definition_categories"] << Tibbr::ApplicationDefinitionCategory.new({:category_id => c, 
            :application_definition_id => self.attributes["id"]})} 
    end
      
    def create
      (multipart? ? multipart_send(create_url,:post) : super).instance_of?(Net::HTTPCreated)
    end

    def update
      unwanted_parameters = ["mtypes", "message_filters", "instances_count", "gloabally_subscribed", "configuration"]
      self.attributes.reject! {|k, v| unwanted_parameters.include?(k)}
      (multipart? ? multipart_send(update_url,:put) : super)
      return false unless errors.empty?
      return true
    end

    
  end
end