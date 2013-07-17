class StoresController < ApplicationController
  require "encryptor"
  # GET /stores
  # GET /stores.json
  def index
    @stores = Store.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stores }
    end
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
    @store = Store.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @store }
    end
  end

  # GET /stores/new
  # GET /stores/new.json
  def new
    @store = Store.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @store }
    end
  end

  # GET /stores/1/edit
  def edit
    @store = Store.find(params[:id])
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(params[:store])

    

    respond_to do |format|
      if @store.save
        # Create the tibbr resource for the store
        puts "rrrrrrr #{@store.id} user: #{@current_user} app_id #{session[:app_id]} "
        action_typ =  "og:comment"
        publish_req = {:message=>{:rich_content=>"New Store !"}, :action_type=>action_typ, :client_id=> session[:app_id], :resource=>{:app_id => session[:app_id], :key => "ID_#{@store.id}", :title => "#{@store.name}_#{@store.name}",:description => "test", :scope => "public", :type => "ad:store", :owners => [@current_user.id], :url => "#{APP_CONFIG[Rails.env]['retail']['root']}#stores/#{@store.country}/#{@store.city}/#{@store.id}", :action_links => [{:url => "#{APP_CONFIG[Rails.env]['retail']['root']}#stores/#{@store.country}/#{@store.city}/#{@store.id}", :label => "View", :display_target => "app"}] }}.to_json;

        #encryptor = Encryptor.new(application_config_decrypt_key, "")
        encryptor = Encryptor.new("947aafe0-e8b1-11e2-9fa4-a4199b34c982", "")
        signed_hash_string = encryptor.encrypt(publish_req)

       #  Tibbr::ExternalResourceAction.publish ({:client_id=> session[:app_id], :signed_hash=> publish_req})
         
        Tibbr::ExternalResourceAction.publish ({:client_id=> session[:app_id], :signed_hash=> signed_hash_string})
         
        tib_res = Tibbr::ExternalResource.find_by_resource_key({:resource => {:key => "ID_#{@store.id}", :resource_type => "ad:store"}, :client_id => session[:app_id]})
        
        @store.tibbr_id = tib_res.id
        @store.tibbr_key = "ID_#{@store.id}"

        
        @store.save
        format.html { redirect_to @store, notice: 'Store was successfully created.' }
        format.json { render json: @store, status: :created, location: @store }
      else
        format.html { render action: "new" }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stores/1
  # PUT /stores/1.json
  def update
    @store = Store.find(params[:id])

    respond_to do |format|
      if @store.update_attributes(params[:store])
        format.html { redirect_to @store, notice: 'Store was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store = Store.find(params[:id])
    @store.destroy

    respond_to do |format|
      format.html { redirect_to stores_url }
      format.json { head :no_content }
    end
  end
  
  
  def followers
    puts 'followers of stores'
    @store = Store.find(params[:id])
    followers = @store.followers
    followers
  end

  def follow
    
    puts "CURRR USER #{@current_user}"
    @store = Store.find(params[:id])
    @store.follow
    
    resultIsFollowing = following?
    
    puts "KKKKK #{resultIsFollowing}"
  # puts "BEFORE FOLLOW #{@current_user}"
   # users = Array.new
   # users << @current_user.login
    #resp = Tibbr::ExternalResource.add_followers({:client_id => session[:app_id], :replace => false, :resource => {:id=>@store.tibbr_id, :resource_type => "ad:store"}, :users=>users})

    respond_to do |format|
        format.json {
      
      json_hash ={:resource => @store,
                  :is_following => resultIsFollowing
                  }
        render json: json_hash.to_json
      
      }
    end
  end
  
  
  
  def unfollow
    
    @store = Store.find(params[:id])
    @store.unfollow
    # users = Array.new
   # users << @current_user.login
   # resp = Tibbr::ExternalResource.remove_followers({:client_id => session[:app_id], :replace => false, :resource => {:key=>@store.tibbr_key, :resource_type => "ad:store"}, :users=>users})
resultIsFollowing = following?
    
    respond_to do |format|
      format.json {
      
      json_hash ={:resource => @store,
                  :is_following => resultIsFollowing
                  }
        render json: json_hash.to_json
      
      }
      
    end
  end
  
  
  def following?
    followers = @store.followers
    return false if followers.nil?
    followers.items.each do |f|
      return true if f.id == @current_user.id
    end

    return false
  end
  
  
end
