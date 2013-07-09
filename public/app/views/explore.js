define([
    'jquery',
    'underscore',
    'backbone',
    'collections/explores',
    'text!templates/explore.html',
], function($, _, Backbone, ItemsCollection, exploreTemplate) {

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
        },
        
        loadResults: function() {
            var that = this;
            

            // we are starting a new load of results so set isLoading to true
            this.isLoading = true;
            // fetch is Backbone.js native function for calling and parsing the collection url
            this.exploreCollection.fetch({
                
                success: function(tweets) {
                    console.log("sssdzdzd "+JSON.stringify(tweets));
                    // Once the results are returned lets populate our template
                   // $(that.el).html(exploreTemplate);
                   
                _.each(tweets.models, function(curentItem,index){
                 //pourquoi $(this.el) ne marche pas  => OK parce que this pas défini, var that = this avant !!?
                 console.log("GET OBJECT:"+JSON.stringify(curentItem));
                 console.log("ssssss "+curentItem.get('name'));
                // $('body').find("#select_items").append('<option id="#'+index+'" class="selectItem" value="'+curentItem.id+'">'+curentItem.reference+'</option>');
                 $(that.el).find("#test_truc").append('<li id="res_'+curentItem.id+'">'
                     +'<div class="resource-details"><div class="resource-info"><h6>'+curentItem.get('name')+'</h6></div>'
                     +'<div class="follow-resource"><a class="follow_resource_button"><span>Follow</span></a></div></div>')
                })
                   // console.log(_.template(exploreTemplate, {tweets: tweets.models[0].get("items"), _: _}));
                   // $(that.el).append(_.template(exploreTemplate, {tweets: tweets.models[0].get("items"), _: _}));
                    // Now we have finished loading set isLoading back to false
                    that.isLoading = false;
                }
            });
        },
        events: {
            'click a#more': 'more',
            'scroll .resource-item-directory':'checkScroll',
            'click .resource_menu ul li' : 'more_menu'
        },
        checkScroll: function() {
            console.log("SCROOOLL");
            var triggerPoint = 100; // 100px from the bottom
            if (!this.isLoading && this.el.scrollTop + this.el.clientHeight + triggerPoint > this.el.scrollHeight) {
                this.exploreCollection.page += 1; // Load next page
                this.loadResults();
            }
        },
        more: function (){
                this.exploreCollection.page += 1; // Load next page
                this.loadResults();
    
        },
        more_menu: function (evt){
            
           
            
            $(this.el).find(".selected").removeClass("selected");
            $(evt.target).addClass("selected");
            
            this.exploreCollection = new ItemsCollection();
            
             if($(evt.target).attr("id")==0){
                 this.exploreCollection.searchTerm="";
             }
            else {
                this.exploreCollection.searchTerm = $(evt.target).attr("id");
            }
            
            // clear previous serach result
            $(this.el).find("#test_truc").empty();
            this.loadResults();
            
        }
    })

    return ExploreView;

})