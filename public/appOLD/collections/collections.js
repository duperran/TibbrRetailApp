define([
    'jquery',
    'backbone',
    'models/item'
], function($, Backbone, Item) {
    var Collections = Backbone.Collection.extend({
        //url: function(){return '/itemType?itemType='+ this.searchTerm +'&format=json'},
        url: function(){return '/retailapp/collections/'+ this.searchTerm +'?format=json'}
       
    });


    return Collections;
});