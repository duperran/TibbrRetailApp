define([
  'jquery',
  'backbone'
], function($, Backbone) {
 var Explores = Backbone.Collection.extend({
                   
            url: function(){
                return '/retailapp/exploreResource?itemType='+ this.searchTerm +'&page='+this.page+'&perpage='+this.perpage+'&format=json'
            
            },
             page: 1,
             perpage:4,
             searchTerm:""

               
            });
            
            
    return Explores;
});