module MetaDetail

  def meta_details(reload=false)
    @form_meta = nil if reload

    @form_meta ||= begin
      old_id = self.id
      self.id ||= "new" # set a dummy id for a new record
      payload_key = self.class.name.demodulize.underscore.to_sym
      get(:meta_details, payload_key => self.attributes).map{|opt| Tibbr::MetaInfo.new(opt)}.sort_by{|m| m.position}
    ensure
      self.id = old_id
    end
  end
  
#  def meta_detail_for attr
#    (meta_details || []).select{|field| field.key.to_s == attr.to_s}.first
#  end
#
#  def has_dyna_field? attr
#    self.respond_to?(attr) or !meta_detail_for(attr).blank?
#  end
#
#  def get_dyna_field_val attr
#    return nil unless has_dyna_field?(attr)
#    send(attr)
#  end

end

module Tibbr
  class MetaInfo
    attr_accessor :key, :type, :ui_type, :multi_value, :required, :label, :description,
                  :position, :default, :allowed_values, :dependency, :filter_value, :has_dependents,:editable
    def initialize(options)
      self.key = options['key']
      self.type = options['type']
      self.ui_type= options['ui_type']
      self.multi_value = options['multi_value'] || false
      self.required = options['required'] || false
      self.label = options['label']
      self.description = options['description']
      self.position = options['position'] || 1
      self.default = options['default']
      self.dependency = _set_dependency(options['dependency'])
      self.filter_value = options['filter_value']
      self.has_dependents = options['has_dependents']
      self.allowed_values = _set_allowed_values(options['allowed_values'])
      self.editable = options.has_key?('editable') ? options['editable'] : true
    end

    private
    def _set_dependency(input)
      return [] if input.empty?
      input.map {|kv| kv['id']}
    end

    def _set_allowed_values(input)
      return [] if input.empty?
      return input.map {|kv| [kv['value'], kv['id']]} if ["select", "list_select"].include?(ui_type.to_s)
      input
    end

  end
end