
require 'common_stuff'
class ExploreController < ApplicationController

  include CommonStuff

  
  def get_ressources_by_name
    
    @results = Array.new
   
    stores = Store.find(:all, :conditions => ["name LIKE ?", "%#{params[:name]}%"])
    items = Item.find(:all, :conditions => ["name LIKE ?", "%#{params[:name]}%"])
    
    
     stores.each do |a|
        # Check if the user is following the store => method in module common_stuff
        a[:is_following] = isfollowingstore? a
      end
      
       items.each do |a|
        # Check if the user is following the item => method in module common_stuff
        a[:is_following] = isfollowingitem? a
      end
    
    @results = stores + items;  
    
    
    respond_to do |format|
     format.json { 
     
        json_hash ={:results => @results.as_json}
        render json: json_hash.to_json
      }
    end
    
  end
  
  def get_ressources
    # Retrieve items & stores
    if(params[:itemType] == '')
      
      items = Item.all
      stores = Store.all
      
      
      stores.each do |a|
        # Check if the user is following the store => method in module common_stuff
        a[:is_following] = isfollowingstore? a
      end
      
       items.each do |a|
        # Check if the user is following the item => method in module common_stuff
        a[:is_following] = isfollowingitem? a
      end
      
      @items = items;
      @stores = stores; 
      
    # Retrieve strores  
    elsif(params[:itemType] == '4')
      stores = Store.all
      
      stores.each do |a|
        # Check if the user is following the item => method in module common_stuff
        a[:is_following] = isfollowingstore? a
      end
      @stores = stores; 
      @items=[];
   
    #Retrieve items
    else
       
      items = Item.find_all_by_item_type_id(params[:itemType])
      
      items.each do |a|
        # Check if the user is following the item => method in module common_stuff
        a[:is_following] = isfollowingitem? a
      end
      
      @items=items;
      @stores = [];
    end
    
    
    respond_to do |format|
      format.html # show.html.erb
      
      format.json { 
     
        json_hash ={:items => @items.count >0?@items.paginate(:page => params[:page],:per_page =>params[:perpage] ).as_json : @items.as_json,
          :count => @items.count + @stores.count,
          :stores =>@stores.count >0?@stores.paginate(:page => params[:page],:per_page =>params[:perpage] ).as_json : @stores.as_json }
        render json: json_hash.to_json
      }
     
    end
     

  end
end