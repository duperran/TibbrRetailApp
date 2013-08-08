define([
   'jquery',
  'backbone'
], function($, Backbone) {
  var Item = Backbone.Model.extend({
                "type":null,
                "reference":null,
                "colors":null,
                "pictures":null,
                
                
            });
  return Item;

});

