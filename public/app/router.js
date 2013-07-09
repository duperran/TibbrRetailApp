// Filename: router.js
define([
  'jquery',
  'underscore',
  'backbone',
  'vm',
  'views/store',
  'views/home',
  'views/item',
  'views/explore'
], function ($, _, Backbone,Vm, StoreView, HomeView, ItemView,ExploreView) {

  var appRouter = Backbone.Router.extend({
    routes: {
      'home/':'home',  
      'stores/': 'stores',
      'stores/:country/:index': 'stores_country',
      'stores/:country/:city/:index': 'stores_country_city',
      'collections/':'collections',
      //'items/:index': 'items',
      'items/:category/:index': 'items_category',
      'explore/':'explore',
    },

    initialize: function(options) {
    this.appView = options.appView;
    },
    home : function(){
        
       var view =  Vm.create(this.appView,'Home',HomeView);
      
        //UNCOMMENT TO ACTIVE WINDOWS

        // $('body').find('section#1').css("display","block");
       
        //this.refreshWindowsScroll();
       view.render();   
    },
    stores : function (index){
       console.log("dans home: "+index);
      
       
       
       //$('html, body').animate({  
        //scrollTop:$('Stores | ').offset().top  
        //}, 'slow'); 
    },
    stores_country :function(){
     console.log("dans stores_country: ");

     },
     stores_country_city: function(country,city,index){
      console.log("dans stores_country_city: "+index);
     // $('body').find('section#1').css("display","none");
       var view =  Vm.create(this.appView,'Stores',StoreView,{index:index});
          
       view.render();

     },
     collections: function(){
      console.log("dans collections: ");

     },
     items: function(){
      console.log("dans items: ");
      


     },       
     items_category: function(category,index){
     console.log("category "+category+" index "+index);

        console.log("dans items_category: ");
        $('body').find('section#1').css("display","none");
      var view =  Vm.create(this.appView,'Item',ItemView,{type:category,index:index});
      view.render();

      //var view = new ItemView({type:category,index:index})
      //view.setElement(this.appView.$('#main-content')).render();
        

     },
    explore: function() {

     var view =  Vm.create(this.appView,'Explore',ExploreView);
      view.render();
    
    
    },
    //UNCOMMENT TO ACTIVE WINDOWS

     /*refreshWindowsScroll: function (){
        var $windows = $('.window');
                
                  $windows.windows({
                    snapping: true,
                    snapSpeed: 500,
                    snapInterval: 1100,
                    onScroll: function(s){},
                    onSnapComplete: function($el){},
                    onWindowEnter: function($el){}
                });
     }*/
            
  });
  
  return appRouter;
});
