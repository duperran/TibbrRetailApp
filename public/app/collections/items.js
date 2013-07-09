define([
    'jquery',
    'backbone',
    'models/item'
], function($, Backbone, Item) {
    var Items = Backbone.Collection.extend({
        //url: function(){return '/itemType?itemType='+ this.searchTerm +'&format=json'},
        url: function(){return '/retailapp/item_types/'+ this.searchTerm +'?format=json'}
       
    });


    return Items;
});


