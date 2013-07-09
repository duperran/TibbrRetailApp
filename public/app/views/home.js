define([
  'jquery',
  'backbone',
  'tibbr',
  'text!templates/home.html',
], function($, Backbone,Tibbr,homeTemplate){
    
    var HomeView = Backbone.View.extend({
        el: '.main-content',
        initialize:function(){
    
        },
         render: function(){
     
     
     
            $(this.el).html(homeTemplate);
            console.log("sssssss "+$(this.el).find(".home_div").html());
           // window.fadeEffect.init('home_div','1');
            $("#home_div").animate({height:"300px"},500);
            $("#home_div").animate({width:"700px"},500, function(){$("#home_div h3").fadeIn(1000)});
           // $("#home_picture_div").backstretch('app/images/zara_model.jpg');
           // $.backstretch('app/images/zara_model.jpg');
            $("#home_picture_div").animate({height:"500px"},500);
            $("#home_picture_div").animate({width:"500px"},500, function(){
                
                $('#home_picture_div').backstretch('app/images/zara_model.jpg');
                $('#home_quote').fadeIn(2000);
            
            
            });
            
           //  $('#home2').backstretch('app/images/zara_home2.jpg');

           
            
           // $("#home_div h3").fadeIn(1000);
            //$("#div3").fadeIn(3000);
            return this;
         }
        
        
    })
    return   HomeView;
})

