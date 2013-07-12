module Tibbr

  class MessageFilter < TibbrResource
    #attributes =>
    #   :name => name/title for the filter
    #   :description => text description
    #   :criterias => Array of Criteria objects
  end

end

#Create_filter
#filter = MessageFilter.new
#filter.criterias = []
#
#crit1 = Criteria.new
#crit1.cfield = :owner
#crit1.cvalue = 5
#
#crit2 = Criteria.new
#crit2.cfield = :subject
#crit2.cvalue = 17
#
#crit3 = Criteria.new
#crit3.cfield = :keywords
#crit3.cvalue = 'silver'
#
#crit4 = Criteria.new
#crit4.cfield = :created_at
#crit4.cvalue = Time.now.to_s
#
#filter.criterias << crit1
#filter.criterias << crit2
#filter.criterias << crit3
#filter.criterias << crit4
#
#filter.save
