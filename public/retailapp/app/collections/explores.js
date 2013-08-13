define([
  'jquery',
  'backbone'
], function($, Backbone) {
 var Explores = Backbone.Collection.extend({
                   
            url: function(){
                return '/retailapp/exploreResource?itemType='+ this.searchTerm +'&page='+this.page+'&perpage='+this.perpage+'&format=json'
            
            },
             page: 1,
             perpage:3, //WILL SHOW 6 lines 3 Stores + 3 Items
             searchTerm:""

               
            });
            
            
    return Explores;
});