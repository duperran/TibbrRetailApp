/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
requirejs.config({
    //By default load any module IDs from js/lib 
    paths:{
    app: '../app',
    baseUrl: 'js/lib',
    jquery: 'js/lib/jquery-min',
    underscore: 'js/lib/underscore-1.4.4', 
    backbone: 'js/lib/backbone-1.0.0',
    text: 'js/lib/text',
    tibbr: 'js/lib/tibbr',
    backstretch :'js/lib/backstretch',
   // windows : 'js/lib/jquery.windows',
    galleria: 'js/lib/gallery/galleria-1.2.9.min',
    
    
    //templates: '../../templates',
    },
    shim: {
        'backbone': {
            //These script dependencies should be loaded before loading
            //backbone.js
            deps: ['underscore', 'jquery'],
            //Once loaded, use the global 'Backbone' as the
            //module value.
            exports: 'Backbone'
        },
        
         'underscore': {
            exports: '_'
        },
        'jquery': {
            exports: '$'
        },
        'backstretch':{
            deps: ['jquery'],
            exports: 'backstretch'
            
        },
       /* 'windows':{
            deps: ['jquery'],
            exports: 'windows'
        },*/
        'galleria':{
           deps: ['jquery'],
           exports: 'Galleria'
        },
        
      
   }
    
});


require([
    'jquery',
    'underscore',
    'backbone',
    'views/index',
    'router',
    'backstretch',
    //'windows',
    'galleria'
    ], function($, _, Backbone, AppView, AppRouter, Backstretch, /*Windows,*/ Galleria) {
        
        function _loadTIB(){
        
        
        var tib = document.createElement('script');
       
        tib.type = 'text/javascript';
        tib.src =  'app/js/lib/tibbr.js';
        document.body.appendChild(tib);
        
        //var galleria = document.createElement('script');
       
        //tib.type = 'text/javascript';
        //tib.src =  'app/js/lib/gallery/galleria.classic.min.js';
       // document.body.appendChild(galleria);
        
     

//UNCOMMENT TO ENABLE WINDOWS LIB
/*$(document).ready(function(){

                var $windows = $('.window');
                console.log("OUIA ");
                $windows.windows({
                    snapping: true,
                    snapSpeed: 500,
                    snapInterval: 1100,
                    onScroll: function(s){},
                    onSnapComplete: function($el){},
                    onWindowEnter: function($el){}
                });
});*/
        
    }
    _loadTIB();
    //This function is called when scripts/helper/util.js is loaded.
    //If util.js calls define(), then this function is not fired until
    //util's dependencies have loaded, and the util argument will hold
    //the module value for "helper/util".
    
    var appView = new AppView;
    appView.render();
    appView.initialize();
    
        
    var appRouter = new AppRouter({appView: appView}); // Router initialization 
    Backbone.history.start(); // Backbone start
   
});

