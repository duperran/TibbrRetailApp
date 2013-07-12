c = APP_CONFIG[Rails.env]['api'] || {}
cs = c['cache_store'] || {}
format = APP_CONFIG[Rails.env]['api']['format'].to_s.downcase.to_sym
#Object.subclasses_of(ActiveResource::Base).map do |klass|
#  klass.format =  format
#end
Tibbr::TibbrResource.site  = c['site']
Tibbr::TibbrResource.per_page= c['per_page']
Tibbr::TibbrResource.client_key = c['client_key']
Tibbr::TibbrResource.cache_ttl =  c['cache_ttl'] || 0
Tibbr::TibbrResource.main_part_id = c['main_part_id']
Tibbr::TibbrResource.attachment_id_prefix = c['attachment_id_prefix']
Tibbr::TibbrResource.assertion_consumer_service_url = "#{c['site']}/login"

unless cs[:type].blank?
  hosts = cs[:host].split(',').each{|ent| ent.strip!}
  Tibbr::TibbrResource.cache_store = cs['type'].to_sym, hosts, { :namespace => cs['namespace'], :timeout => cs['timeout']}
end