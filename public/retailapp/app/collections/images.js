define([
  'jquery',
  'backbone'
], function($, Backbone) {
 var Pictures = Backbone.Collection.extend({
               url: function(){return '/retailapp/resourcepictures'+this.searchTerm +'&format=json'},
               initialize: function(models,options){
             
               } 
            });
            
            
    return Pictures;
});
