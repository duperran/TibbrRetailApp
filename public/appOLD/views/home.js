define([
    'jquery',
    'backbone',
    'text!templates/home.html',
], function($, Backbone, homeTemplate) {

    var HomeView = Backbone.View.extend({
        el: '.main-content',
        initialize: function() {
        // console.log("RAILS ENV"+RAILS_RELATIVE_URL_ROOT)


        },
        render: function() {

            $(this.el).html(homeTemplate);
           
               TIB.parentApp.setFrameHeight($("#container").height());
 // WE SET THE CONNECTED USER HERE BECAUSE WE ARE SURE THAT THE VIEW HAS BEEN RENDERED       
  // document.getElementById('user_connected').innerHTML += current_user.display_name;
            return this;
        },
        
                


    })
    return   HomeView;
})

