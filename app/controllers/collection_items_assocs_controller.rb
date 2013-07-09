class CollectionItemsAssocsController < ApplicationController
  # GET /collection_items_assocs
  # GET /collection_items_assocs.json
  def index
    @collection_items_assocs = CollectionItemsAssoc.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @collection_items_assocs }
    end
  end

  # GET /collection_items_assocs/1
  # GET /collection_items_assocs/1.json
  def show
    @collection_items_assoc = CollectionItemsAssoc.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @collection_items_assoc }
    end
  end

  # GET /collection_items_assocs/new
  # GET /collection_items_assocs/new.json
  def new
    @collection_items_assoc = CollectionItemsAssoc.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @collection_items_assoc }
    end
  end

  # GET /collection_items_assocs/1/edit
  def edit
    @collection_items_assoc = CollectionItemsAssoc.find(params[:id])
  end

  # POST /collection_items_assocs
  # POST /collection_items_assocs.json
  def create
    @collection_items_assoc = CollectionItemsAssoc.new(params[:collection_items_assoc])

    respond_to do |format|
      if @collection_items_assoc.save
        format.html { redirect_to @collection_items_assoc, notice: 'Collection items assoc was successfully created.' }
        format.json { render json: @collection_items_assoc, status: :created, location: @collection_items_assoc }
      else
        format.html { render action: "new" }
        format.json { render json: @collection_items_assoc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /collection_items_assocs/1
  # PUT /collection_items_assocs/1.json
  def update
    @collection_items_assoc = CollectionItemsAssoc.find(params[:id])

    respond_to do |format|
      if @collection_items_assoc.update_attributes(params[:collection_items_assoc])
        format.html { redirect_to @collection_items_assoc, notice: 'Collection items assoc was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @collection_items_assoc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_items_assocs/1
  # DELETE /collection_items_assocs/1.json
  def destroy
    @collection_items_assoc = CollectionItemsAssoc.find(params[:id])
    @collection_items_assoc.destroy

    respond_to do |format|
      format.html { redirect_to collection_items_assocs_url }
      format.json { head :no_content }
    end
  end
end
