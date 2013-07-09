define([
   'jquery',
  'backbone'
], function($, Backbone) {
  var ResourceType = Backbone.Model.extend({
                "id":null,
                "name":null,
                "display_ame":null,
                "url":null,
                "parent_id":null,
                
            });
  return ResourceType;

});

