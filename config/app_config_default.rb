unless defined?(API_CONFIG)
  API_CONFIG = {
    :table_name_prefix => "hg",
    :prod_name =>   "TIBCO tibbr retail",
    :company_name =>  "TIBCO Software Inc.",
    :expiration_time =>  "1.year",
    :vote_notifications => false,
    :profile_sync_interval => "24.hours",
    :api =>{
      :site => "https://tibbr.localdomain.com/tibbr",
      :per_page => 100,
      :client_key => "tibbr_retail32994309843dskdskjshkhkfs987w98whjdskjhkjdsh",
      :cache_ttl => 60,
      :cache_enable => true,
      :main_part_id => "main",
      :post_subscription_messages_count => 10,
      :attachment_id_prefix => "tibbr_attachment",
      :format => :json
    },
    :retail =>{
        :root => "http://tibbr.localdomain.com/retail/"
    },
    :eval_instance => false,
    :authorise_user => false
  }
end