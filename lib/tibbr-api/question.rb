
module Tibbr
  class Question < TibbrResource
    #attributes =>
#    def initialize(object_hash = {})
#      object_hash.delete("question_options") if object_hash.keys.include?("question_options")
#      super
#    end
    
    def multi_select
      attributes['multi_select']
    end

    def allow_others_to_add_options
      attributes['allow_others_to_add_options']
    end

    def multi_select=(value)
      attributes['multi_select']=value
    end

    def allow_others_to_add_options=(value)
      attributes['allow_others_to_add_options']=value
    end

    def question_options
      @question_options = self.attributes["question_options"] || []
    end

    # question.answer({:question_option_id=>1})
    def answer(options = {})
       options.merge!(:set_actions => true)
       load_from_response(put(:answer, :params => options))
    end

    # question.unanswer({:question_option_id=>1})
    def unanswer(options = {})
       options.merge!(:set_actions => true)
       load_from_response(put(:unanswer, :params => options))
    end

    # question.add_question_option(:question_option=>{:option_label=>"ABC", :position=>1})
    def add_question_option(options = {})
      options.merge!(:set_actions => true)
      load_from_response(put(:add_question_option, :params => options))
    end

    # question.remove_question_option({:question_option_id=>1})
    def remove_question_option(options = {})
      options.merge!(:set_actions => true)
      load_from_response(put(:remove_question_option, :params => options))
    end

    # question.get_option_users(option.id, :per_page => 20, :page => params[:page])
    def get_option_users(*args)
      question_options_id, page, per_page = TibbrResource.extract_params(args)
      TibbrResource.paginate_collection(get(:get_option_users, :params => {:question_options_id => question_options_id, :page=> page, :per_page=>per_page}),User)
    end

    def update_cached_message user
      messages = (Tibbr::User.cache_lookup(user.cache_key, "messages")||[]).select { |m|  m.id == self.message_id }
      msg = messages.first
      if msg
        msg.question = self
        Tibbr::Message.update_cache(user, msg)
      end
    end

  end
end