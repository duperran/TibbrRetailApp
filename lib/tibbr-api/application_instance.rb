module Tibbr
  class ApplicationInstance  < TibbrResource

    # all(:include_deleted => true)   - will return all application_instances including the deleted ones.
    # all(:include_deleted => false)  - will return all application_instances excluding the deleted ones.
    # all()                           - will return all application_instances excluding the deleted ones.
    def self.all(options = {})
      find(:all, :params => (options || {}).slice(:include_deleted))
    end

    def enable
      put(:enable).instance_of?(Net::HTTPOK)
    end

    def disable
      put(:disable).instance_of?(Net::HTTPOK)
    end

    def delete
      load_from_response(put(:delete))
    end

    def undelete
      load_from_response(put(:undelete))
    end

    def application_config
      return attributes['application_config'] if defined?(@application_config_init)
      @application_config_init = true
      ac = attributes['application_config']
      return ac if (ac.nil? || ac.is_a?(Tibbr::ApplicationConfig))
      ac.attributes.delete('configurable_type')
      ac.attributes.delete('configurable_id')
      ac.attributes['application_instance_id'] = attributes['id']
      config = ac.attributes.delete('configuration').try(:attributes) || {}
      attributes['application_config'] = Tibbr::ApplicationConfig.new(ac.attributes.merge(config))
    end

    def application_definition
      return attributes['application'] if defined?(@application_definition_init)
      @application_definition_init = true
      ad = attributes['application']
      return ad if (ad.nil? || ad.is_a?(Tibbr::ApplicationDefinition))
      filters = ad.attributes.delete('message_filters')
      nad=Tibbr::ApplicationDefinition.new(ad.attributes)
      nad.message_filters = filters
      attributes['application'] = nad
    end

    def update
      attributes.delete_if {|key, value| ["application", "application_statistic", "user"].include? key }
      load_from_response(super)
    end

  end
end
