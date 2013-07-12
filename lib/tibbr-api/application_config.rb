module Tibbr
class ApplicationConfig  < TibbrResource
  include MetaDetail

  def data_sources
    return attributes['data_sources'] if defined?(@data_sources_init)
    @data_sources_init = true
    dss = (attributes['data_sources'] ||=[]) # need to initialize the value
    return dss if (dss.empty? || dss.first.is_a?(Tibbr::ApplicationDataSourceConfig))
    # TODO remove this hack after the server side sends the proper attributes
    attributes['data_sources'] = dss.map do |ds|
      config = ds.attributes.delete('configuration').try(:attributes) || {}
      ds.attributes.delete('configurable_type')
      ds.attributes.delete('configurable_id')
      ds.attributes['application_config_id'] = attributes['id']
      Tibbr::ApplicationDataSourceConfig.new(ds.attributes.merge(config))
    end
  end

end
end