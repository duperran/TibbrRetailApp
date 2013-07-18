define([
    'jquery',
    'underscore',
    'backbone',
    'collections/explores',
    'collections/images',
    'views/resourceType',
    'text!templates/explore.html',
], function($, _, Backbone, ItemsCollection, ImagesCollection,ResourceTypeListView, exploreTemplate) {

    var ExploreView = Backbone.View.extend({
        el: ".main-content",
        initialize: function(options) {
            // isLoading is a useful flag to make sure we don't send off more than
            // one request at a time
            this.isLoading = false;
            this.exploreCollection = new ItemsCollection();
            this.vent = this.options.vent; 
        },
        render: function() {
            $(this.el).html(exploreTemplate)
            this.loadResults();

            if (this.exploreCollection.models.length > 0)
                this.load_pictures();
        },
        loadResults: function() {
            var that = this;


            // we are starting a new load of results so set isLoading to true
            this.isLoading = true;
            // fetch is Backbone.js native function for calling and parsing the collection url
            this.exploreCollection.fetch({
                success: function(resources) {
                    $(that.el).find('#more_ul').show();
                    var count = $(that.el).find("#test_truc").children().size() + resources.models[0].get("items").length + resources.models[0].get("stores").length
                    if ($(that.el).find("#test_truc").children().size() + resources.models[0].get("items").length + resources.models[0].get("stores").length== resources.models[0].get("count")) {
                        $(that.el).find('#more_ul').hide();
                    }

                   
                    // Display items
                    _.each(resources.models[0].get("items"), function(curentItem, index) {
                       
                        //pourquoi $(this.el) ne marche pas  => OK parce que this pas défini, var that = this avant !!?
                        // $('body').find("#select_items").append('<option id="#'+index+'" class="selectItem" value="'+curentItem.id+'">'+curentItem.reference+'</option>');
                        
                        
                              var classButtonFollow = ""
                        var textButtonFollow = ""

                        if (curentItem.is_following) {
                            classButtonFollow = "unfollow_resource_button"
                            textButtonFollow = "unfollow"

                        }
                        else {
                            classButtonFollow = "follow_resource_button"
                            textButtonFollow = "follow"

                        }
                        
                        
                        
                        $(that.el).find("#test_truc").append('<li id="res_' + curentItem.id + '">'
                                + '<div class="resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="app/images/default_pic.jpeg"></div><h6>' + curentItem.name + '</h6></div>'
                                + '<div class="follow-resource"><a class="'+classButtonFollow+'" type="item" resourceid=' + curentItem.id + '><span>'+textButtonFollow +'</span></a></div></div>')
                    })

                    // Display stores
                    _.each(resources.models[0].get("stores"), function(curentItem, index) {
                        
                        //pourquoi $(this.el) ne marche pas  => OK parce que this pas défini, var that = this avant !!?
                        console.log("STORES GET OBJECT:" + JSON.stringify(curentItem));
                        // $('body').find("#select_items").append('<option id="#'+index+'" class="selectItem" value="'+curentItem.id+'">'+curentItem.reference+'</option>');


                        var classButtonFollow = ""
                        var textButtonFollow = ""

                        if (curentItem.is_following) {
                            classButtonFollow = "unfollow_resource_button"
                            textButtonFollow = "unfollow"

                        }
                        else {
                            classButtonFollow = "follow_resource_button"
                            textButtonFollow = "follow"

                        }

                        $(that.el).find("#test_truc").append('<li id="res_' + curentItem.id + '">'
                                + '<div class="resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="app/images/default_pic.jpeg"></div><h6>' + curentItem.name + '</h6></div>'
                                + '<div class="follow-resource"><a class="' + classButtonFollow + '" type="store" resourceid=' + curentItem.id + '><span>' + textButtonFollow + '</span></a></div></div>')


                    })


                    // Now we have finished loading set isLoading back to false
                    that.isLoading = false;



                    _.each(resources.models[0].get("items"), function(curentItem, index) {

                        that.load_pictures(curentItem);

                    })

                }
            });
        },
        events: {
            'click a#more': 'more',
            'scroll .resource-item-directory': 'checkScroll',
             'click .resource_menu ul li span': 'more_menu',
            'click .follow_resource_button ': 'follow',
            'click .unfollow_resource_button': 'unfollow'
        },
        checkScroll: function() {
            var triggerPoint = 100; // 100px from the bottom
            if (!this.isLoading && this.el.scrollTop + this.el.clientHeight + triggerPoint > this.el.scrollHeight) {
                this.exploreCollection.page += 1; // Load next page
                this.loadResults();
            }
        },
        more: function() {
            this.exploreCollection.page += 1; // Load next page
            this.loadResults();

        },
        more_menu: function(evt) {


            $(this.el).find(".selected").removeClass("selected");
            
            
            $(evt.target).parent().addClass("selected");

            this.exploreCollection = new ItemsCollection();

            if ($(evt.target).parent().attr("id") == 0) {
                this.exploreCollection.searchTerm = "";
            }
            else {
                this.exploreCollection.searchTerm = $(evt.target).parent().attr("id");
            }

            // clear previous serach result
            $(this.el).find("#test_truc").empty();
            this.loadResults();

        },
        load_pictures: function(currImage) {
            var that = this;
            pic = new ImagesCollection;
            pic.searchTerm = "?item_id=" + currImage.id + "&first_pic=true";

            pic.fetch({
                success: function(result) {

                    if (result.models.length > 0) {
                        //$(that.el).find("li#res_"+currImage.id).find(".item_pic").css("background-image",'url("'+result.models[0].get("thumb")+'")');
                        $(that.el).find("li#res_" + currImage.id).find(".pic").attr("src", result.models[0].get("thumb"));
                    }
                }

            });


        },
        follow: function(evt) {
            var that = this;

            if ($(evt.target).parent().attr("type") == "store") {


    
                request = $.ajax({
                    url: "/retailapp/followStore",
                    type: "get",
                    data: {format: "json",
                        id: $(evt.target).parent().attr("resourceid")
                    },
                    success: function(response) {
                        that.manageFollowCommand(response);
                        console.log("TRIGGER customEvent")
                        //tirgger event to update stores list in menu and reflect the change 
                        that.vent.trigger("test:customEvent")

                         // 
                         
                        // Not so good ... reset the header menu to reflect 'follow' update
                       // var header = new ResourceTypeListView;
                       // header.setElement(that.$('#header_ul')).render();

                    }
                });
            }else{
                request = $.ajax({
                    url: "/retailapp/followItem",
                    type: "get",
                    data: {format: "json",
                        id: $(evt.target).parent().attr("resourceid")
                    },
                    success: function(response) {
                        that.manageFollowCommand(response);

                    }
                });
            }
            


        },
        unfollow: function(evt) {
            var that = this;

            if ($(evt.target).parent().attr("type") == "store") {


                request = $.ajax({
                    url: "/retailapp/unfollowStore",
                    type: "get",
                    data: {format: "json",
                        id: $(evt.target).parent().attr("resourceid")
                    },
                    success: function(response) {
                        that.manageFollowCommand(response);
                        console.log("TRIGGER customEvent")
                        //tirgger event to update stores list in menu and reflect the change 
                        //that.event_aggregator.trigger("test:customEvent")
                         
                         that.vent.trigger("test:customEvent")

                         // Not so good ... reset the header menu to reflect 'follow' update
                        //var header = new ResourceTypeListView;
                        //header.setElement(that.$('#header_ul')).render();


                        
                        // $(that).find("#test_truc").find('a[resourceid ="' + $(evt.target).parent().attr("resourceid") + '"]').attr("class","follow_resource_button")
                    }
                });
                
            }
            else{
                request = $.ajax({
                    url: "/retailapp/unfollowItem",
                    type: "get",
                    data: {format: "json",
                        id: $(evt.target).parent().attr("resourceid")
                    },
                    success: function(response) {
                        that.manageFollowCommand(response);
                       
                    }
                });
            }

        },
        manageFollowCommand: function (resource,target){
            if(resource.is_following == true){
               $(this.el).find("#test_truc").find('a[resourceid ="' + resource.resource.id+'"]').attr("class","unfollow_resource_button")
               $(this.el).find("#test_truc").find('a[resourceid ="' + resource.resource.id+'"]').children("span").text("unfollow")
               
            }
            else{
                $(this.el).find("#test_truc").find('a[resourceid ="' +resource.resource.id+'"]').attr("class","follow_resource_button")
                $(this.el).find("#test_truc").find('a[resourceid ="' + resource.resource.id+'"]').children("span").text("follow")

            }
        }
    })

    return ExploreView;

})