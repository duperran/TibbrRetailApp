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
        var that = this;
        this.stores = new StoresCollection;
        this.stores.searchTerm = "/"+options.index;
        this.stores.bind("change", this.render);
        this.gadget_url = "http://tibbr.localdomain.com/a/gadgets/resource_messages.html";
        this.stores.fetch({
            success: function(collection,response){
                
                console.log("resp:"+JSON.stringify(response));
                 that.gadget_url += '?client_id=75&type=ad:store&key='+response.tibbr_key
                 that.render();
            },
            update:true        
        })
    },

    render : function(){
        
        //$(this.el).html(StoresTemplate,test);
        var tmpl = _.template(StoresTemplate)
       
        $(this.el).html(tmpl({gadget_url:this.gadget_url}))
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


