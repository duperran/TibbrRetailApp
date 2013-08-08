define([
  'jquery',
  'backbone'
], function($, Backbone) {
 var Stores = Backbone.Collection.extend({
               url: function(){return '/retailapp/stores'+this.searchTerm+'?format=json'},
               initialize: function(models,options){
             
               } 
            });
            
            
    return Stores;
});