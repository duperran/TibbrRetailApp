module Tibbr

  class Criteria < TibbrResource
    #attributes =>
    #   :cfield => criteria to be applied on field. can be only one of [:owner, :subject, :keywords, :created_at]
    #   :cvalue => value of the corresponding :cfield to match
    #   :coperator => comparison operator e.g. ['==', '>', '<']. Defaults to '=='. This is only used for :created_at.
  end

  class CriteriaEntity < TibbrResource

  end

end