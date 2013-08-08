define([
  'jquery',
  'backbone',
  'text!templates/home.html',
], function($, Backbone,NotFound){
  
    var CollectionView = Backbone.View.extend({
    el: '.main-content',
        initialize:function(){
            
        },
         render: function(){
     
            //$(this.el).html(NotFound);

         }
         
    }); 
    
    return CollectionView;
})
