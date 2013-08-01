define([
  'jquery',
  'underscore',
  'backbone',
  'collections/stores',
  'collections/resourcesType',
  'collections/collections',
  'views/resourceType_item',
], function($, _, Backbone,StoresCollection,ResourcesCollection,LinesCollection,ResourceTypeItemView){
    
    var resources = Backbone.View.extend({
    el:'#header_ul2',
    id:'header_ul2',
    tagName:'ul',
    initialize: function(options){
      //  console.log("dans ressource view" +$(this.el).html())
        this.collection = new ResourcesCollection;
        this.stores = new StoresCollection;
        this.lines = new LinesCollection;
          _.bindAll(this);
        this.options.vent.bind("test:customEvent", this.refresh);
        
       // this.event_aggregator.trigger("test:customEvent")
        //console.log("ssqsffgg "+this.collection.size())
        
    },
                  
    render: function(){
        console.log("HOP")
                 var that = this;
                 
                 //console.log("Dans Render resourceTypeList view "+ $(this.el).html());
                 var collect = this.collection;

                      
                      
                 _.each(this.collection.models, function(currentRestype,index){
                     
                     var currentItem = new ResourceTypeItemView({resource:currentRestype, url_target:currentRestype.get("url")+"/"+currentRestype.get("resource_id")});

                     if(currentRestype.get("parent_id") == null){
                       
                        $(this.el).append(currentItem.render().el);
                        

                     }
                     else{
                         if ($(this.el).find('#li'+currentRestype.get("parent_id")).find("ul#mine").length == 0){
                             
                              $(this.el).find('#li'+currentRestype.get("parent_id")).append('<ul id="mine"></ul>');
                             
                             // THIS LINE IS FOR BOOTSTRAP
                             //$(this.el).find('#li'+currentRestype.get("parent_id")).append('<ul id="mine" class="dropdown-menu"></ul>');
                         }
                       
                         $(this.el).find('#li'+currentRestype.get("parent_id")).find("ul").append(currentItem.render().el);
                     }
                  },this);
                  
                  this.stores.searchTerm='';
                  this.stores.fetch({
                      
                      success:function(collection,response){
                          
                          
                          _.each(response, function (currStore,index){
                              

                              
                              
                              if($(that.el).find("#"+currStore.city).parent().find("ul").length ==0){
                                 $(that.el).find("#"+currStore.city).parent().append('<ul></ul>')
                             // THIS LINE IS FOR BOOTSTRAP

                                //  $(that.el).find("#"+currStore.city).parent().append('<ul class="dropdown-menu"></ul>')
                                  
                              } 
                              //HACK
                              $(that.el).find("#"+currStore.city).parent().find('ul').append('<li class="li_menu" id="li_store'+currStore.id+'"><a href="#stores/'+currStore.country+'/'+currStore.city+'/'+currStore.id+'"id="'+currStore.name+'">'+currStore.name+'</a></li>')
                              //
                            }
                          
                          )
                      },
                     error:function (){
                     }         
                      
                  })
                  
                  // COLLECTION SECTION
                   this.lines.searchTerm='';
                  this.lines.fetch({
                      success: function (){
                          
                      }
                  });
                  
          
           // WE SET THE CONNECTED USER HERE BECAUSE WE ARE SURE THAT THE VIEW HAS BEEN RENDERED       
          // document.getElementById('user_connected').innerHTML += current_user.display_name;

                  return this;
       
            },   
            refresh:function (){
                
               
                console.log("refresh")
        this.collection = new ResourcesCollection;
        this.stores = new StoresCollection;
        this.lines = new LinesCollection;
        
        $(this.el).empty();
        this.render();
               
            },
            //doSomething: function (){
          //  console.log("eee")
            
           // },
          
    
    })
    
    return resources;
    
    
})

