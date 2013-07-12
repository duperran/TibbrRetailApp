class ItemsController < ApplicationController
  # GET /items
  # GET /items.json
  def index
    @items = Item.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
      
      
      
      
    end
  end
  
  def get_items_by_type
    
   
    if(params[:itemType] == '')
      
        @item = Item.all
        puts "la"
    else
       @item = Item.find_all_by_item_type_id(params[:itemType])
       puts "ici"
      
    end   
    
    puts "Count: #{@item.count}"
    
    respond_to do |format|
      format.json { 
        json_hash ={:items => @item.paginate(:page => params[:page],:per_page =>params[:perpage]).as_json,:count =>@item.count}
        render json: json_hash.to_json
       }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
    itemType = ItemType.find(@item.item_type_id)
    puts "item #{ItemType.find(@item.item_type_id).name}"
    @item.pictures = Picture.find(:all)
    puts "pictures : #{@item.pictures}"
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item.to_json(:include => {:pictures => @item})}

    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = Item.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(params[:item])

    
     
    
    
    respond_to do |format|
      if @item.save
        
        # Create the tibbr resource for the item
        action_typ =  "og:comment"
        itemTypeName =ItemType.find(@item.item_type_id).name.downcase 
        publish_req = {:message=>{:rich_content=>"New #{itemTypeName} model has been created !"}, :action_type=>action_typ, :client_id=> session[:app_id], :resource=>{:app_id => session[:app_id], :key => "Item_#{@item.id}_#{@item.reference}", :title => "#{@item.reference}_#{@item.name}",:description => "test", :scope => "public", :type => "ad:item", :owners => [@current_user.id], :url => "#{APP_CONFIG[Rails.env]['retail']['root']}#items/#{itemTypeName}/#{@item.id}", :action_links => [{:url => "#{APP_CONFIG[Rails.env]['retail']['root']}#items/#{itemTypeName}/#{@item.id}", :label => "View", :display_target => "app"}] }}.to_json;

        #encryptor = Encryptor.new(application_config_decrypt_key, "")
        encryptor = Encryptor.new("947aafe0-e8b1-11e2-9fa4-a4199b34c982", "")
        signed_hash_string = encryptor.encrypt(publish_req)

       #  Tibbr::ExternalResourceAction.publish ({:client_id=> session[:app_id], :signed_hash=> publish_req})
         
        Tibbr::ExternalResourceAction.publish ({:client_id=> session[:app_id], :signed_hash=> signed_hash_string})
         
        tib_res = Tibbr::ExternalResource.find_by_resource_key({:resource => {:key => "ID_#{@store.id}", :resource_type => "ad:store"}, :client_id => session[:app_id]})
        
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :no_content }
    end
  end
end
