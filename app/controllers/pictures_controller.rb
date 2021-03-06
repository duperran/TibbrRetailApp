class PicturesController < ApplicationController
  # GET /pictures
  # GET /pictures.json
  def index
    @pictures = Picture.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pictures }
    end
  end

  # METHOD USE TO RETRIEVE PHOTO OF ITEMS OR STORES, WE CHECK IF STORE ID OR ITEM ID IS SET TO DETERMINE WHAT PIC TO LOAD
   def getresourcepicture
    
     if(params[:store_id])
       
         @pictures = Picture.find_all_by_store_id(params[:store_id]); 
     
     end
     if(params[:item_id])
     
          @pictures = Picture.find_all_by_item_id(params[:item_id]); 

    
    elsif(params[:first_pic] =='true')
      
      @pictures = @pictures.first();
      
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pictures }
    end
    
  end
  
  def getstorepicture
    
    @pictures = Picture.find_all_by_store_id(params[:store_id]); 
    if(params[:first_pic] =='true')
      
      @pictures = @pictures.first();
      
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pictures }
    end
    
  end
  
  def getitempicture
    @pictures = Picture.find_all_by_item_id(params[:item_id]); 
    
    if(params[:first_pic] =='true')
      
      @pictures = @pictures.first();
      
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pictures }
    end
    
  end
  # GET /pictures/1
  # GET /pictures/1.json
  def show
    @picture = Picture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @picture }
    end
  end

  # GET /pictures/new
  # GET /pictures/new.json
  def new
    @picture = Picture.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @picture }
    end
  end

  # GET /pictures/1/edit
  def edit
    @picture = Picture.find(params[:id])
  end

  # POST /pictures
  # POST /pictures.json
  def create
    @picture = Picture.new(params[:picture])

    respond_to do |format|
      if @picture.save
        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        format.json { render json: @picture, status: :created, location: @picture }
      else
        format.html { render action: "new" }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pictures/1
  # PUT /pictures/1.json
  def update
    @picture = Picture.find(params[:id])

    respond_to do |format|
      if @picture.update_attributes(params[:picture])
        format.html { redirect_to @picture, notice: 'Picture was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pictures/1
  # DELETE /pictures/1.json
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy

    respond_to do |format|
      format.html { redirect_to pictures_url }
      format.json { head :no_content }
    end
  end
end
