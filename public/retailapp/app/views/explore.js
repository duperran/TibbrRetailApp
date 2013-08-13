define([
    'jquery',
    'underscore',
    'backbone',
    'collections/explores',
     'collections/autocompleteExplore',
    'collections/images',
    'views/resourceType',
    'text!templates/explore.html',
], function($, _, Backbone, ItemsCollection, ExploreAutoCollection ,ImagesCollection,ResourceTypeListView, exploreTemplate) {

    var ExploreView = Backbone.View.extend({
        el: ".main-content",
        initialize: function(options) {
            // isLoading is a useful flag to make sure we don't send off more than
            // one request at a time
            this.isLoading = false;
            this.exploreCollection = new ItemsCollection();
            this.vent = this.options.vent;
            this.autoExploreCollection = new ExploreAutoCollection();
        },
        render: function() {
            $(this.el).html(exploreTemplate)
            $(this.el).find('.bubblingG').css("display","block");

            this.loadResults();

            if (this.exploreCollection.models.length > 0)
                this.load_pictures();
            
             TIB.parentApp.setFrameHeight($("#container").outerHeight(true)+50);

        },
        loadResults: function() {
            var that = this;


            // we are starting a new load of results so set isLoading to true
            this.isLoading = true;
            // fetch is Backbone.js native function for calling and parsing the collection url
            this.exploreCollection.fetch({
                success: function(resources) {
                    //Hide wait spinners 
                    $(that.el).find('.bubblingG').css("display","none");
                    $(that.el).find('#floatingCirclesG').css("display","none");

                    $(that.el).find('#more_ul').show();
                    var count = $(that.el).find("#test_truc").children().size() + resources.models[0].get("items").length + resources.models[0].get("stores").length
                    if ($(that.el).find("#test_truc").children().size() + resources.models[0].get("items").length + resources.models[0].get("stores").length== resources.models[0].get("count")) {
                        $(that.el).find('#more_ul').hide();
                    }

                   
                    // Display items
                    _.each(resources.models[0].get("items"), function(curentItem, index) {
                       
                    
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
                        
                        
                        
                        $(that.el).find("#test_truc").append('<li id="res_item_' + curentItem.id + '">'
                                + '<div class="explore-resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="/retailapp/app/images/default_pic.jpeg"></div><h5>' + curentItem.name + '</h5></div>'
                                + '<div class="follow-resource"><a class="'+classButtonFollow+'" type="item" resourceid=' + curentItem.id + '><span>'+textButtonFollow +'</span></a></div></div>')
                    
                       that.load_pictures(curentItem,"item_id");
                    
                    })

                    // Display stores
                    _.each(resources.models[0].get("stores"), function(curentItem, index) {
                        
                        //pourquoi $(this.el) ne marche pas  => OK parce que this pas défini, var that = this avant !!?
                        //console.log("STORES GET OBJECT:" + JSON.stringify(curentItem));
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

                        $(that.el).find("#test_truc").append('<li id="res_store_' + curentItem.id + '">'
                                + '<div class="explore-resource-details"><div class="resource-info"><div class="item_pic"  ><img class="pic" src="/retailapp/app/images/default_pic.jpeg"></div><h5>' + curentItem.name + '</h5></div>'
                                + '<div class="follow-resource"><a class="' + classButtonFollow + '" type="store" resourceid=' + curentItem.id + '><span>' + textButtonFollow + '</span></a></div></div>')

                        that.load_pictures(curentItem,"store_id");
                    })


                    // Now we have finished loading set isLoading back to false
                    that.isLoading = false;



                    //_.each(resources.models[0].get("items"), function(curentItem, index) {

                   //     that.load_pictures(curentItem);

                    //})

                }
            });

        },
        events: {
            'click a#more': 'more',
            'scroll .resource-item-directory': 'checkScroll',
             'click .resource_menu ul li span': 'more_menu',
            'click .follow_resource_button ': 'follow',
            'click .unfollow_resource_button': 'unfollow',
            'focus .search_box_input': 'getAutocomplete',
            'click .search_button' : 'searchResources',
            'mouseover .pic': 'modal_pic',
            'mouseout .pic' : 'close_modal_pic',

        },
        modal_pic: function (){
            $('#myModal_pics').tooltip("show");
        },
        close_modal_view: function(){
           $('#myModal_pics').tooltip("hide");
        },        
        //NOT USED
        checkScroll: function() {
            var triggerPoint = 100; // 100px from the bottom
            if (!this.isLoading && this.el.scrollTop + this.el.clientHeight + triggerPoint > this.el.scrollHeight) {
                this.exploreCollection.page += 1; // Load next page
                this.loadResults();
            }
        },
        more: function() {
            $(this.el).find('#floatingCirclesG').css("display","block");

            this.exploreCollection.page += 1; // Load next page
            this.loadResults();


        },
        more_menu: function(evt) {
            //show main spinner
            $(this.el).find('.bubblingG').css("display","block");

            //Clean the search box
            $(this.el).find(".search_box_input").val('');
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
        //WE USE THE SAME METHOD FOR DISPLAYING THE PIC OF STORE AND ITEM, SO I NEED TO PASS THE SEARCH PARAMETER        
        load_pictures: function(currImage,search_param){
            var that = this;
            pic = new ImagesCollection;
            pic.searchTerm = "?"+search_param+"="+currImage.id+"&first_pic=true";

            pic.fetch({
                success: function(result) {

                    if (result.models.length > 0) {
                        //$(that.el).find("li#res_"+currImage.id).find(".item_pic").css("background-image",'url("'+result.models[0].get("thumb")+'")');
                        
                        if(search_param =="store_id"){
                            $(that.el).find("li#res_store_" + currImage.id).find(".pic").attr("src", result.models[0].get("thumb"));
                        }
                        else{
                            
                            $(that.el).find("li#res_item_" + currImage.id).find(".pic").attr("src", result.models[0].get("thumb"));

                        }
                        
                        
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
                        //tirgger event to update stores list in menu and reflect the change 
                        that.vent.trigger("test:customEvent")

                    
                         
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
                        
                         
                         that.vent.trigger("test:customEvent")

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
        },
         getAutocomplete: function () {
            var that = this;
            $(".search_box_input").autocomplete({
                   minLength: '3',
                   source: function (request, response){
                     
                     
                     that.autoExploreCollection.searchTerm = $(".search_box_input").val();
                     var resources = that.autoExploreCollection.fetch({
                         async:false,
                        
                     });
                     var resourcesJSON = $.parseJSON(resources.responseText);
                     
                  
                      
                     response($.map(resourcesJSON.results,function(item,i) {
                                 return {label : item.name,
			                 value : item.name,
                                         it: i,
					}
	              }));
                      
                      
                                
                    
                 },
                 open: function(){
                 },        
                 select: function(event, ui) {
                  
                    var plop = that.autoExploreCollection.models[0].get("results");
                    $(that.el).find("#test_truc").empty();
                     that.exploreCollection = new ItemsCollection([plop[ui.item.it]]);

                    
                                 // Display items
                    _.each(that.exploreCollection.models, function(curentItem, index) {

                        var classButtonFollow = ""
                        var textButtonFollow = ""

                        if (curentItem.get('is_following')) {
                            classButtonFollow = "unfollow_resource_button"
                            textButtonFollow = "unfollow"

                        }
                        else {
                            classButtonFollow = "follow_resource_button"
                            textButtonFollow = "follow"

                        }
                        
                         var typeOfResource = ""
                        //Check if the result is a store or an item to handle the follow unfollow which check the type of resource
                        if ( typeof curentItem.get("item_type_id") == 'undefined'){
                            typeOfResource = 'store'
                        }
                     
                        
                        
                         if(typeOfResource == 'store'){
                             $(that.el).find("#test_truc").append('<li id="res_store_' + curentItem.get('id') + '">'
                                + '<div class="explore-resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="/retailapp/app/images/default_pic.jpeg"></div><h5>' + curentItem.get('name') + '</h5></div>'
                                + '<div class="follow-resource"><a class="'+classButtonFollow+'" type="'+typeOfResource+'" resourceid=' + curentItem.get('id') + '><span>'+textButtonFollow +'</span></a></div></div>')
                    
                              that.load_pictures(curentItem,"store_id");

                         }
                         else{
                             $(that.el).find("#test_truc").append('<li id="res_item_' + curentItem.get('id') + '">'
                                + '<div class="explore-resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="/retailapp/app/images/default_pic.jpeg"></div><h5>' + curentItem.get('name') + '</h5></div>'
                                + '<div class="follow-resource"><a class="'+classButtonFollow+'" type="'+typeOfResource+'" resourceid=' + curentItem.get('id') + '><span>'+textButtonFollow +'</span></a></div></div>')
                    
                              that.load_pictures(curentItem,"item_id");

                         }
                    
                    })
                    
                    
                    
                 }
                
            });
         },
         searchResources: function(){
              this.autoExploreCollection.searchTerm = $(".search_box_input").val();
               this.autoExploreCollection.fetch({
                         async:false,
                        
                     });
             $(this.el).find("#test_truc").empty();
             $(this.el).find('#more_ul').hide();
             console.log("ffff "+JSON.stringify(this.exploreCollection))
             this.exploreCollection = new ItemsCollection(this.autoExploreCollection.models[0].get("results"));
             
             var that = this;
             _.each(this.exploreCollection.models, function(curentItem, index) {

                        var classButtonFollow = ""
                        var textButtonFollow = ""

                        if (curentItem.get('is_following')) {
                            classButtonFollow = "unfollow_resource_button"
                            textButtonFollow = "unfollow"

                        }
                        else {
                            classButtonFollow = "follow_resource_button"
                            textButtonFollow = "follow"

                        }
                        
                        var typeOfResource = ""
                        //Check if the result is a store or an item to handle the follow unfollow which check the type of resource
                        if ( typeof curentItem.get("item_type_id") == 'undefined'){
                            typeOfResource = 'store'
                        }
                     
                        
                       
                      if(typeOfResource == 'store'){
                              
                      $(that.el).find("#test_truc").append('<li id="res_store' + curentItem.get('id') + '">'
                                + '<div class="explore-resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="/retailapp/app/images/default_pic.jpeg"></div><h5>' + curentItem.get('name') + '</h5></div>'
                                + '<div class="follow-resource"><a class="'+classButtonFollow+'" type="'+typeOfResource+'" resourceid=' + curentItem.get('id') + '><span>'+textButtonFollow +'</span></a></div></div>')
                  
                          that.load_pictures(curentItem,"store_id");
                              

                         }
                         else{
                              $(that.el).find("#test_truc").append('<li id="res_item_' + curentItem.get('id') + '">'
                                + '<div class="explore-resource-details"><div class="resource-info"><div class="item_pic"><img class="pic" src="/retailapp/app/images/default_pic.jpeg"></div><h5>' + curentItem.get('name') + '</h5></div>'
                                + '<div class="follow-resource"><a class="'+classButtonFollow+'" type="'+typeOfResource+'" resourceid=' + curentItem.get('id') + '><span>'+textButtonFollow +'</span></a></div></div>')
                  
                              that.load_pictures(curentItem,"item_id");

                         }
             
                })
 
         }
                
    })

    return ExploreView;

})