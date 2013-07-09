define([
  'jquery',
  'backbone',
  'text!templates/coverFlow.html',
], function($, Backbone,coverFlowTemplate){
    
    var HomeView = Backbone.View.extend({
        el: '#cover_div',
        initialize:function(models, options){
             console.log("WHat ?");
             if(options !=null){
                this.pics = options.pictures;
                //this.pics.bind("change", this.render);

                
             }  
        },
         events: {
          "click #galleriass" : "fullscreen",
         },       
         render: function(){
            console.log("dddddddd");
             $(this.el).html(coverFlowTemplate);
             
             console.log("DDZDZ" +this.pics);
             
            // Load the classic theme
            Galleria.loadTheme('app/js/lib/gallery/galleria.classic.min.js');

            // Initialize Galleria
            
            Galleria.configure({
                imageCrop: true,
                transition: 'fade'
            });



            Galleria.run('#galleria',{dataSource: this.pics});
  
            Galleria.ready(function() {
                var gallery = this; // galleria is ready and the gallery is assigned
                $('#galleria').click(function() {
                //    gallery.toggleFullscreen(); // toggles the fullscreen
                });
            });
  
            console.log("apres galeria");
            return this;
         },
         fullscreen : function(){
             Galleria.fullscreen(); 
         }
        
        
    })
    return   HomeView;
})
