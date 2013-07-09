define([
  'jquery',
  'backbone',
  'tibbr',
  'text!templates/home.html',
], function($, Backbone,Tibbr,homeTemplate){
  
    var CollectionView = Backbone.View.extend({
    el: '.main-content',
        initialize:function(){
            
        },
         render: function(){
     
     
         }
         
    }); 
    
    return CollectionView;
})
