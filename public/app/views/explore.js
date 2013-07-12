define([
    'jquery',
    'underscore',
    'backbone',
    'collections/explores',
    'collections/images',
    'text!templates/explore.html',
], function($, _, Backbone, ItemsCollection, ImagesCollection, exploreTemplate) {

    var ExploreView = Backbone.View.extend({
        el: ".main-content",
        initialize: function() {
            // isLoading is a useful flag to make sure we don't send off more than
            // one request at a time
            this.isLoading = false;
            this.exploreCollection = new ItemsCollection();

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
                success: function(tweets) {
                    $(that.el).find('#more_ul').show();
                    if ($(that.el).find("#test_truc").children().size() + tweets.models[0].get("items").length == tweets.models[0].get("count")) {
                        $(that.el).find('#more_ul').hide();
                    }

                    //       console.log("sssdzdzd "+JSON.stringify(tweets.models[0].get("items").length));
                    // Once the results are returned lets populate our template
                    // $(that.el).html(exploreTemplate);

                    // Display items
                    _.each(tweets.models[0].get("items"), function(curentItem, index) {
                        //pourquoi $(this.el) ne marche pas  => OK parce que this pas défini, var that = this avant !!?
                        console.log("GET OBJECT:" + JSON.stringify(curentItem));
                        // $('body').find("#select_items").append('<option id="#'+index+'" class="selectItem" value="'+curentItem.id+'">'+curentItem.reference+'</option>');
                        $(that.el).find("#test_truc").append('<li id="res_' + curentItem.id + '">'
                                + '<div class="resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="app/images/default_pic.jpeg"></div><h6>' + curentItem.name + '</h6></div>'
                                + '<div class="follow-resource"><a class="follow_resource_button" type="item" resourceid=' + curentItem.id + '><span>Follow</span></a></div></div>')
                    })

                    // Display stores
                    _.each(tweets.models[0].get("stores"), function(curentItem, index) {
                        //pourquoi $(this.el) ne marche pas  => OK parce que this pas défini, var that = this avant !!?
                        console.log("GET OBJECT:" + JSON.stringify(curentItem));
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



                    // console.log(_.template(exploreTemplate, {tweets: tweets.models[0].get("items"), _: _}));
                    // $(that.el).append(_.template(exploreTemplate, {tweets: tweets.models[0].get("items"), _: _}));
                    // Now we have finished loading set isLoading back to false
                    that.isLoading = false;



                    _.each(tweets.models[0].get("items"), function(curentItem, index) {

                        that.load_pictures(curentItem);

                    })

                }
            });
        },
        events: {
            'click a#more': 'more',
            'scroll .resource-item-directory': 'checkScroll',
            'click .resource_menu ul li': 'more_menu',
            'click .follow_resource_button ': 'follow',
            'click .unfollow_resource_button': 'unfollow'
        },
        checkScroll: function() {
            console.log("SCROOOLL");
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
            $(evt.target).addClass("selected");

            this.exploreCollection = new ItemsCollection();

            if ($(evt.target).attr("id") == 0) {
                this.exploreCollection.searchTerm = "";
            }
            else {
                this.exploreCollection.searchTerm = $(evt.target).attr("id");
            }

            // clear previous serach result
            $(this.el).find("#test_truc").empty();
            this.loadResults();

        },
        load_pictures: function(currImage) {
            var that = this;
            console.log(JSON.stringify(currImage));
            pic = new ImagesCollection;
            pic.searchTerm = "?item_id=" + currImage.id + "&first_pic=true";

            pic.fetch({
                success: function(result) {

                    if (result.models.length > 0) {
                        console.log('ou')
                        //$(that.el).find("li#res_"+currImage.id).find(".item_pic").css("background-image",'url("'+result.models[0].get("thumb")+'")');
                        $(that.el).find("li#res_" + currImage.id).find(".pic").attr("src", result.models[0].get("thumb"));
                    }
                }

            });


        },
        follow: function(evt) {
            that = this;
            console.log("FOLLOW" + $(evt.target).parent().attr("resourceid"));

            if ($(evt.target).parent().attr("type") == "store") {



                request = $.ajax({
                    url: "/retailapp/followStore",
                    type: "get",
                    data: {format: "json",
                        id: $(evt.target).parent().attr("resourceid")
                    },
                    success: function(response) {
                        console.log("SUCCESS");
                        $(that).find("#test_truc").find('a[resourceid ="' + $(evt.target).parent().attr("resourceid") + '"]').attr("class","unfollow_resource_button")
                    }
                });
            }

        },
        unfollow: function(evt) {
            that = this;
            console.log("FOLLOW" + $(evt.target).parent().attr("resourceid"));

            if ($(evt.target).parent().attr("type") == "store") {


                request = $.ajax({
                    url: "/retailapp/unfollowStore",
                    type: "get",
                    data: {format: "json",
                        id: $(evt.target).parent().attr("resourceid")
                    },
                    success: function(response) {
                        console.log("SUCCESS");
                        $(that).find("#test_truc").find('a[resourceid ="' + $(evt.target).parent().attr("resourceid") + '"]').attr("class","follow_resource_button")
                    }
                });
            }

        }
    })

    return ExploreView;

})