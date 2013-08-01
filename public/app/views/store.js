define([
    'jquery',
    'underscore',
    'backbone',
    'collections/stores',
    'text!templates/store.html'
], function($, _, Backbone, StoresCollection, StoresTemplate) {

    var StoreView = Backbone.View.extend({
        el: '.main-content',
        initialize: function(options) {
            var that = this;
            this.stores = new StoresCollection;
            this.stores.searchTerm = "/" + options.index;
            this.stores.bind("change", this.render);
            this.gadget_url = "http://"+RAILS_RELATIVE_URL_ROOT+"/a/gadgets/resource_messages.html";
            
            this.stores.fetch({
                success: function(collection, response) {

                    console.log("resp:" + JSON.stringify(response));
                    that.gadget_url += '?client_id=75&type=ad:store&key=' + response.tibbr_key
                    that.render();
                },
                update: true
            })
        },
        events: {
            'click #store_panel_map': 'display_map'
        },
        render: function() {

            //$(this.el).html(StoresTemplate,test);
            // to avoid first render before collection get initialized
            if (this.stores.models.length > 0) {
                var tmpl = _.template(StoresTemplate)
                console.log("stores" + JSON.stringify(this.stores))
                $(this.el).html(tmpl({gadget_url: this.gadget_url}))
                $(this.el).find('#store_panel_desc1').append('<h3>' + this.stores.models[0].get("name") + '</h3>')
                $(this.el).find('#store_panel_desc1').append('<h4>' + this.stores.models[0].get("street_number") + " " + this.stores.models[0].get("street") + '</h4>')
                $(this.el).find('#store_panel_desc1').append('<h4>' + this.stores.models[0].get("city") + "," + this.stores.models[0].get("country") + '</h4>')


                TIB.parentApp.setFrameHeight($("#main-content").outerHeight(true));
            }
           
            // $("#left").animate({height:"700px"},300);
            //  $("#left").animate({width :"400px"},300, function (){
            //      $("#shops_info").find('hgroup').delay(10).fadeIn(1000);
            //        $("#tib_container_store").delay(100).animate({height:"610px"},600);
            //          $("#tibbr_wall").delay(100).fadeIn(1000);
            //  });





            return this;
        },
        display_map: function() {
             
            var position = $('#main-content').position();
            $('#myModal').css("margin-top", position.top + 40);
            $('#myModal').modal("show");
           
           // timeout used to avoid the problem of map size, because the view is modal the map does not fill the DIV
            var that = this;
            setTimeout(function() {
                that.initMap();
            }, 500);
          
             google.maps.event.trigger(map, "resize");

   



        },
        initMap: function() {
            // Call this function when the page has been loaded 
            map = new google.maps.Map(document.getElementById("map"));

console.log("long "+this.stores.models[0].get("longitude"))
console.log("lat "+this.stores.models[0].get("latitude"))

            var long = this.stores.models[0].get("longitude")

            var lat = this.stores.models[0].get("latitude")

            var deptName = this.stores.models[0].get("name") 

            var center = new google.maps.LatLng(lat, long);

            map.setZoom(9);

            map.setCenter(center);

            var marker = new google.maps.Marker({position: center, map: map});

            marker.setMap(map);
                google.maps.event.trigger(map, "resize");

         

        }

    });

    return StoreView;
})


