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
          $(this.el).html('<a href="#'+this.url_target+'" id="'+this.model.get("name")+'">'+this.model.get("name")+'</a>');
          $(this.el).attr('id', 'li'+this.model.get("id"))
          
        // BOOTSTRAP  
        
  //  $(this.el).append('<a class="dropdown-toggle" data-toggle="dropdown" href="#'+this.url_target+'" id="'+this.model.get("name")+'">'+this.model.get("name")+'</a>');
        // END BOOTSTRAP
          //  $(this.el).attr('id', 'li'+this.model.get("id")).addClass('dropdown')
            //console.log("sssssss "+$(this.el).html());
          return this;
        } ,
                
         showOrigin: function(evt){
         },
        
        
    }
        
    
    
    
    )
     
    return ResourceTypeItem
    
    
})

