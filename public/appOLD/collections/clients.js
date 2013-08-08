define([
  'jquery',
  'backbone'
], function($, Backbone) {
 var Clients = Backbone.Collection.extend({
               initialize: function(models,options){
                   
                   this.bind("add",options.view.addClientToList);
                   this.bind("remove",options.view.deleteFromList);
               } 
            });
            
            
    return Clients;
});
