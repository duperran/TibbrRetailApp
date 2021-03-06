define([
  'jquery',
  'underscore',
  'backbone',
  'models/client',
  'collections/clients',
  'views/resourceType',
  'views/home',
  'views/coverflow',
  'text!templates/app.html',
], function($,_,Backbone,Client,Clients,ResourceTypeListView,HomeView,CoverFlowView,layoutTemplate){
    
    var appView = Backbone.View.extend({
             el:$('body'),
             initialize:function(options){

                this.clients = new Clients(null,{view:this});
                this.itemsIterr = 0;
                this.vent= this.options.vent;
             
         
             },
             render: function(){
                 
                 $(this.el).find('.header_menu').html(layoutTemplate);

                 this.header = new ResourceTypeListView({vent:this.vent});
                 this.mainContentDefault = new HomeView;
                 //this.coverFlow = new CoverFlowView;

      
                 this.header.setElement(this.$('#header_ul')).render();
                 this.mainContentDefault.setElement(this.$('#main-content')).render();
  
                
                 
                 return this;
                },
             events: {
             "click #add-client" : "showPrompt",
              "click .button-remove":"deleteFromCollection",       
             },
             showPrompt : function(){
          
                 var client_name = prompt("Who is your client ?");
                 this.itemsIterr +=1;
                 var new_client = new Client({name:client_name,id:this.itemsIterr});
                 this.clients.add(new_client);
                 
             },
              addClientToList: function(model){
          
                    $('#list_client').append("<li>"+model.get('name')+"<button class=button-remove id="+model.get('id')+">"+"remove"+"</button>"+"</li>");
          
              },
               deleteFromCollection: function(ev){
                   
                     thisitem = this.clients.get($(ev.target).attr("id"));
                     this.clients.remove(thisitem);
                   
                    
               },
               deleteFromList: function(model){
                  //  console.log(model.get('name'));
                    $('#list_client').find("#"+model.get('id')).parent().remove();
               },
                       
              
            
            });
            
            
       return appView;
})




