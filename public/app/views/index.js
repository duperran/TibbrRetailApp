define([
  'jquery',
  'backbone',
  'models/client',
  'collections/clients',
  'views/resourceType',
  'views/home',
  'views/coverflow',
  'text!templates/app.html',
], function($, Backbone,Client,Clients,ResourceTypeListView,HomeView,CoverFlowView,layoutTemplate){
    
    var appView = Backbone.View.extend({
             el:$('body'),
             initialize:function(){
                 // console.log("lllllaaaaa " +$(this.el).html());

                this.clients = new Clients(null,{view:this});
                this.itemsIterr = 0;
               
             
         
             },
             render: function(){
                 
               //  console.log("ddddd "+$(this.el).text())
                 $(this.el).find('.header_menu').html(layoutTemplate);
                 this.header = new ResourceTypeListView;
                 this.mainContentDefault = new HomeView;
                 this.coverFlow = new CoverFlowView;

      
                 this.header.setElement(this.$('#header_ul')).render();
                 this.mainContentDefault.setElement(this.$('#main-content')).render();
                 
                 //if($('body').find("section#1").length == 0){
                   //  console.log("add element");
                     //$('<section id="1" class="window"><div id="home2" class="home2"></div></section>').insertAfter("section#0");
                 //}
                 
//                this.coverFlow.setElement(this.$('#cover_div')).render();
                
                 
                 

                 //console.log("return");
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
                 //console.log(this.clients.size());
                 
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




