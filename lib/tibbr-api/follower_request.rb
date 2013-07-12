module Tibbr
  class FollowerRequest < TibbrResource
    attr_accessor :follower, :actions
    def initialize(object_hash = {})
      self.follower ||= object_hash["follower"].present? ? User.new(object_hash.delete("follower")) : nil
      self.actions ||= ['accept', 'reject']
      super
    end
  end
end