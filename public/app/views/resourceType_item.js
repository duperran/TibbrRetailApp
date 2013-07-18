define([
  'jquery',
  'backbone',
  'models/resourceType',
  'text!templates/resourceType_item.html'
], function($, Backbone,Client,ResourceTypeItem,ResourceTypeItemLayout){
    
    var ResourceTypeItem = Backbone.View.extend({
        tagName:'li',       
        initialize: function(options){

            this.model = this.options.resource;
            this.url_target = this.options.url_target;
           
        },
        events:{
          "click .li_menu" : "showOrigin"  
        },
        render: function(){
          var that = this;
          console.log("gggg "+JSON.stringify(this.model));
          $(this.el).html('<li class="li_menu" id="li'+this.model.get("id")+'"><a href="#'+this.url_target+'" id="'+this.model.get("name")+'">'+this.model.get("name")+'</a></li>');
          //console.log("sssssss "+$(this.el).html());
          return this;
        } ,
                
         showOrigin: function(evt){
            console.log($(evt.target).parent().first().attr("id"));
         },
        
        
    }
        
    
    
    
    )
     
    return ResourceTypeItem
    
    
})

