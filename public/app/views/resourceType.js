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
    el:'#header_ul',
    id:'header_ul',
    tagName:'ul',
    initialize: function(){
      //  console.log("dans ressource view" +$(this.el).html())
        this.collection = new ResourcesCollection;
        this.stores = new StoresCollection;
        this.lines = new LinesCollection;
        //console.log("ssqsffgg "+this.collection.size())
        
    },
            
    render: function(){
                 var that = this;
                 
                 //console.log("Dans Render resourceTypeList view "+ $(this.el).html());
                 var collect = this.collection;

                      
                      
                 _.each(this.collection.models, function(currentRestype,index){
                     // console.log("dans la boucle " );
                      //console.log(currentRestype.get("id"));
                       
                     var currentItem = new ResourceTypeItemView({resource:currentRestype, url_target:currentRestype.get("url")+"/"+currentRestype.get("resource_id")});

                     if(currentRestype.get("parent_id") == null){
                        // console.log("dans IF");
                        //$(this.el).append('<li id="li'+currentRestype.get("id")+'"><a href="#">'+currentRestype.get("name")+'</a></li>');
                        $(this.el).append(currentItem.render().el);
                     }
                     else{
                         //console.log('else');
                         if ($(this.el).find('#li'+currentRestype.get("parent_id")).find("ul#mine").length == 0){
                             
                              $(this.el).find('#li'+currentRestype.get("parent_id")).append('<ul id="mine"></ul>');
                         }
                       
                         $(this.el).find('#li'+currentRestype.get("parent_id")).find("ul").append(currentItem.render().el);
                     }
                  },this);
                  
                  this.stores.searchTerm='';
                  this.stores.fetch({
                      success:function(collection,response){
                          
                          
                          _.each(response, function (currStore,index){
                              
                              console.log("cc "+JSON.stringify(currStore));

                              
                              
                              console.log("EL: "+$(that.el).find("#Paris").text())
                               console.log("Country: "+currStore.city+" "+$(that.el).find("#"+currStore.city).text());
                              if($(that.el).find("#"+currStore.city).parent().find("ul").length ==0){
                                  console.log("HHHHH");
                                  $(that.el).find("#"+currStore.city).parent().append("<ul></ul>")
                                  
                              } 
                              //HACK
                              $(that.el).find("#"+currStore.city).parent().find('ul').append('<li class="li_menu" id="li_store'+currStore.id+'"><a href="#stores/'+currStore.country+'/'+currStore.city+'/'+currStore.id+'"id="'+currStore.name+'">'+currStore.name+'</a></li>')
                              //
                            }
                          
                          )
                      },
                     error:function (){
                        console.log("oups");
                     }         
                      
                  })
                   this.lines.searchTerm='';
                  this.lines.fetch({
                      success: function (){
                          
                      }
                  });
                  return this;
       
            },        
    
    
    
    })
    
    return resources;
    
    
})
