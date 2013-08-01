// Filename: router.js
define([
  'jquery',
  'underscore',
  'backbone',
  'vm',
  'views/store',
  'views/home',
  'views/item',
  'views/explore',
  'views/collection'
], function ($, _, Backbone,Vm, StoreView, HomeView, ItemView,ExploreView,CollectionView) {

  var appRouter = Backbone.Router.extend({
    routes: {
      '/':'home',  
      'home/':'home',  
      'stores/': 'stores',
      'stores/:country/:index': 'stores_country',
      'stores/:country/:city/:index': 'stores_country_city',
      'collections/':'collections',
      //'items/:index': 'items',
      'items/:category/:index': 'items_category',
      'items/:category/:index/:resourceid': 'items_category',
      'explore/':'explore',
      'explore/:categroy':'explore',
    },

    initialize: function(options) {
    this.appView = options.appView;
    this.vent = options.vent;
    },
    home : function(){
        console.log("HOME")
       var view =  Vm.create(this.appView,'Home',HomeView);
       $(document).ready(function() {
    
   $('#myCarousel').carousel({
      interval: 3200
    })
  });
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
      var view =  Vm.create(this.appView,'Collections',CollectionView);
          
       view.render();

     },
     items: function(){
      console.log("dans items: ");
      


     },       
     items_category: function(category,index,resourceid){
     console.log("category "+category+" index "+index);

        console.log("dans items_category: ");
        $('body').find('section#1').css("display","none");
      var view =  Vm.create(this.appView,'Item',ItemView,{type:category,index:index,resourceid:resourceid});
      view.render();

      //var view = new ItemView({type:category,index:index})
      //view.setElement(this.appView.$('#main-content')).render();
        

     },
    explore: function(category) {
     

     var view =  Vm.create(this.appView,'Explore',ExploreView,{vent:this.vent,category:category});
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
