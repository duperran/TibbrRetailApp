define([
    'jquery',
    'backbone',
    'tibbr',
    'text!templates/home.html',
], function($, Backbone, Tibbr, homeTemplate) {

    var HomeView = Backbone.View.extend({
        el: '.main-content',
        initialize: function() {

        },
        render: function() {


$.noConflict();


window.onload =
function()
{
   
    
}
            $(this.el).html(homeTemplate);
            console.log("sssssss " + $(this.el).find(".home_div").html());
 //$(document).ready(function() {
            console.log("ddddddddddd "+$('#my_carousel'))
           

            //    $('#my_carousel').carousel({
   //                 interval: 2200
            //    })
           // });
   //  var res = this.mine($('#my_carousel'))
   
           
            // window.fadeEffect.init('home_div','1');
            // $("#home_div").animate({height:"300px"},500);
            // $("#home_div").animate({width:"700px"},500, function(){$("#home_div h3").fadeIn(1000)});
            // $("#home_picture_div").backstretch('app/images/zara_model.jpg');
            // $.backstretch('app/images/zara_model.jpg');
            //  $("#home_picture_div").animate({height:"500px"},500);
            //  $("#home_picture_div").animate({width:"500px"},500, function(){

            //     $('#home_picture_div').backstretch('app/images/zara_model.jpg');
            //     $('#home_quote').fadeIn(2000);


            //});

            //  $('#home2').backstretch('app/images/zara_home2.jpg');



            // $("#home_div h3").fadeIn(1000);
            //$("#div3").fadeIn(3000);
            return this;
        },
        mine:function (o,i){
    if(typeof i=='undefined')i='';
    if(i.length>50)return '[MAX ITERATIONS]';
    var r=[];
    for(var p in o){
        var t=typeof o[p];
        r.push(i+'"'+p+'" ('+t+') => '+(t=='object' ? 'object:'+this.mine(o[p],i+'  ') : o[p]+''));
    }
    return r.join(i+'\n');
    }
        
                


    })
    return   HomeView;
})

