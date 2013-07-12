
require 'common_stuff'
class ExploreController < ApplicationController

  include CommonStuff

  def get_ressources

    if(params[:itemType] == '')
      
      items = Item.all
      stores = Store.all
      
      
      stores.each do |a|
        # Check if the user is following the store => method in module common_stuff
        a[:is_following] = isfollowingstore? a
      end
      
      @items = items;
      @stores = stores; 
      puts "la"
      
    elsif(params[:itemType] == '4')
      stores = Store.all
      
      stores.each do |a|
        # Check if the user is following the store => method in module common_stuff
        a[:is_following] = isfollowingstore? a
      end
      @stores = stores; 
      puts "edddzdz #{@stores}"
      @items=[];
    else
       
      items = Item.find_all_by_item_type_id(params[:itemType])
      
      
      @items=items;
      @stores = [];
      puts "ici"
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