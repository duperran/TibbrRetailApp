define([
  'jquery',
  'backbone',
  'text!templates/coverFlow.html',
], function($, Backbone,coverFlowTemplate){
    
    var HomeView = Backbone.View.extend({
        el: '#cover_div',
        initialize:function(models, options){
             if(options !=null){
                this.pics = options.pictures;
                //this.pics.bind("change", this.render);
        this.isFullscreen=false;
                
             }  
        },
         events: {
          "click #galleriaxx" : "fullscreen",
         },       
         render: function(){
             $(this.el).html(coverFlowTemplate);
             
             
            // Load the classic theme
            Galleria.loadTheme('app/js/lib/gallery/galleria.classic.min.js');

            // Initialize Galleria
            
            Galleria.configure({
                imageCrop: true,
                transition: 'fade'
            });



            Galleria.run('#galleria',{dataSource: this.pics});
            
            Galleria.ready(function() {
            
            /**if($('#fullscreen').length == 0){
            $(".galleria-info").append('<div class="fullscreen"><a id="fullscreen" class="fullscreen" fullscreen="on">toggle</a></div>');
            }
                $("#fullscreenssss").click(function (){
                    if ($("#fullscreen").attr("fullscreen")=="on"){
                            gallery.toggleFullscreen();
                          //  $("#fullscreen").attr("fullscreen","off")

                    }
                    else{
                        // gallery.exitFullscreen();
                        // $("#fullscreen").attr("fullscreen","on")


                    }

                })**/
                var gallery = this; // galleria is ready and the gallery is assigned
                
                $('#galleriazzzz').dblclick(function() {
                    console.log(isFullscreen)
                    if(!that.isFullscreen){
                        gallery.toggleFullscreen();
                        isFullscreen = true;
                    }
                    else{
                        gallery.exitFullscreen();
                        isFullscreen = false;

                    }
                });
                
                
            });
            
            return this;
         },
         fullscreen : function(){
             Galleria.fullscreen(); 
         }
        
        
    })
    return   HomeView;
})
