module Tibbr
class Schedule < TibbrResource

  # returns a DOW object. This can be used in the views.
  # E.g:
  #  <% form_for @schedule do |schedule_form| %>
  #    ...
  #    <% schedule_form.fields_for :active_days do |active_days_fields| %>
  #       <span> Sun <span/><%= active_days_fields.check_box :sun %>
  #       <span> Mon <span/><%= active_days_fields.check_box :mon %>
  #       <span> Tue <span/><%= active_days_fields.check_box :tue %>
  #       <span> Wed <span/><%= active_days_fields.check_box :wed %>
  #       <span> Thu <span/><%= active_days_fields.check_box :thu %>
  #       <span> Fri <span/><%= active_days_fields.check_box :fri %>
  #       <span> Sat <span/><%= active_days_fields.check_box :sat %>
  #    <% end %>
  #  <% end %>
  def active_days
    @aactive_days ||= DOW.new(attributes["active_days"] || 0, lambda {|v| self.attributes["active_days"] = v})
  end

  def to_xml(options={})
    attributes["active_days"] = self.active_days.dow unless attributes["active_days"].is_a?(Fixnum)
    super
  end

  # There are three methods for every day of the week.
  # E.g:
  #   ad.sun  # returns true if Sun is selected.
  #   ad.sun? # returns true if Sun is selected.
  #   ad.sun = true # selects Sun.
  #   ad.on_days => ["sun", "mon"]
  #   ad.off_days => ["tue", "wed", "thu", "fri", "sat"]
  class DOW
    NOD = %w(sun mon tue wed thu fri sat)
    attr_accessor :dow
    attr_accessor :callback
    
    def initialize (value=0, cb=nil)
      @dow = prepare_dow value
      @callback = cb
    end

    def dow=(value)
      return self.dow unless (value.is_a?(Fixnum) or value.is_a?(Hash) or value.respond_to?(:attributes))
      value = prepare_dow(value) if value.is_a?(Hash) or value.respond_to?(:attributes)
      return self.dow if (self.dow == value)
      callback.call(value) unless callback.nil?
      @dow = value
    end
    
    def prepare_dow value
      return value if value.is_a?(Fixnum)
      h, ret =  HashWithIndifferentAccess.new(value.respond_to?(:attributes) ? value.attributes : value), 0
      NOD.each do |day|
        ret |= self.send("#{day}_flag") if (h[day] == true) or (h[day] == 1)
      end
      ret
    end
    
    NOD.each_with_index do |day, i|
      code = <<-end_code
        def #{day}_flag; 1 << #{i} ;end
        def #{day}; (#{day}_flag & @dow) > 0 ;end
        def #{day}?; #{day} ;end
        def #{day}=(flag); self.dow = (flag ? ( dow | #{day}_flag ) : (dow & ~#{day}_flag)) ;end    
      end_code
      silence_warnings { class_eval code, __FILE__, __LINE__ }
    end
    
    # returns the selected days
    def on_days
      NOD.select {|day| self.send(day)} 
    end

    def off_days
      NOD.select {|day| !self.send(day)}       
    end
  end
end
end