require 'common_stuff'
class ItemTypesController < ApplicationController
    include CommonStuff

  # GET /item_types
  # GET /item_types.json
  def index
    @item_types = ItemType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @item_types }
    end
  end

  # GET /item_types/1
  # GET /item_types/1.json
  def show
    

   
   # Get items filtered by type (shoes, jeans...)
    @item_type = ItemType.find(params[:id])
    allitems = @item_type.item
    
    # Check what are the items the current_user is following
    @itemsFollowed = Array.new
    allitems.each do |item|
      if (isfollowingitem? item)
              @itemsFollowed << item

      end
      
      
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { #render json: @item_type.to_json(:include => {:item => @item_type}) 
        
        json_hash ={:resource => @item_type,
                  :item => @itemsFollowed
                  }
        render json: json_hash.to_json
      }
    end
  end

  # GET /item_types/new
  # GET /item_types/new.json
  def new
    @item_type = ItemType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item_type }
    end
  end

  # GET /item_types/1/edit
  def edit
    @item_type = ItemType.find(params[:id])
  end

  # POST /item_types
  # POST /item_types.json
  def create
    @item_type = ItemType.new(params[:item_type])

    respond_to do |format|
      if @item_type.save
        format.html { redirect_to @item_type, notice: 'Item type was successfully created.' }
        format.json { render json: @item_type, status: :created, location: @item_type }
      else
        format.html { render action: "new" }
        format.json { render json: @item_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /item_types/1
  # PUT /item_types/1.json
  def update
    @item_type = ItemType.find(params[:id])

    respond_to do |format|
      if @item_type.update_attributes(params[:item_type])
        format.html { redirect_to @item_type, notice: 'Item type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /item_types/1
  # DELETE /item_types/1.json
  def destroy
    @item_type = ItemType.find(params[:id])
    @item_type.destroy

    respond_to do |format|
      format.html { redirect_to item_types_url }
      format.json { head :no_content }
    end
  end
end
