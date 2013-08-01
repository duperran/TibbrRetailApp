define([
  'jquery',
  'backbone'
], function($, Backbone) {
 var autocompleteRes = Backbone.Collection.extend({
                   
            url: function(){
                return '/retailapp/searchByName?name='+ this.searchTerm
            
            },
             page: 1,
             perpage:4,
             searchTerm:""

               
            });
            
            
    return autocompleteRes;
});

