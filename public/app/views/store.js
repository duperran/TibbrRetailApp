define([
  'jquery',
  'underscore',
  'backbone',
  'collections/stores',
  'text!templates/store.html'
], function($, _, Backbone,StoresCollection,StoresTemplate){
  
var StoreView = Backbone.View.extend({
    el:'.main-content', 
    initialize: function(options){
        console.log("plop");
        this.stores = new StoresCollection;
        this.stores.searchTerm = "/"+options.index;
        this.stores.bind("change", this.render);

        this.stores.fetch({
            success: function(collection,response){
                
                console.log("resp:"+JSON.stringify(response));
            },
            update:true        
        })
    },
    render : function(){
        console.log("ENTER RENDER:"+JSON.stringify(this.stores))
        $(this.el).html(StoresTemplate);
        $("#left").animate({height:"700px"},300);
        $("#left").animate({width :"400px"},300, function (){
            $("#shops_info").find('hgroup').delay(10).fadeIn(1000);
              $("#tib_container_store").delay(100).animate({height:"610px"},600);
                $("#tibbr_wall").delay(100).fadeIn(1000);
        });
        
        

        
       
        return this;
    }
    
});

   return StoreView; 
})


