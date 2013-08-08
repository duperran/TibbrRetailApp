define([
    'jquery',
    'backbone',
    'models/item'
], function($, Backbone, Item) {
    var Items = Backbone.Collection.extend({
        url: function(){return '/retailapp/item_types/'+ this.searchTerm +'?format=json'}
       
    });


    return Items;
});


