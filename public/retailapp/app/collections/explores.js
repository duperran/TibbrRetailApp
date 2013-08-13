define([
  'jquery',
  'backbone'
], function($, Backbone) {
 var Explores = Backbone.Collection.extend({
                   
            url: function(){
                return '/retailapp/exploreResource?itemType='+ this.searchTerm +'&page='+this.page+'&perpage='+this.perpage+'&format=json'
            
            },
             page: 1,
             perpage:5, //WILL SHOW 10 lines 5 Stores + 5 Items
             searchTerm:""

               
            });
            
            
    return Explores;
});