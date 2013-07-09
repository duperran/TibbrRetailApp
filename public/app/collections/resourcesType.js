define([
  'jquery',
  'backbone',
  'models/resourceType'
], function($, Backbone, ResourceType) {
 var ResourcesType = Backbone.Collection.extend({
               initialize: function(models,options){
                  
                  var sample0 = new ResourceType({name:"Home | ",url:"home",id:"0",parent_id:null,resource_id:""});
                  var sample1 = new ResourceType({name:"Stores | ",url:"stores",id:"1",parent_id:null,resource_id:""});
                  var sample2 = new ResourceType({name:"Collections | ",url:"collections",id:"2",parent_id:null,resource_id:""});
                  var sample3 = new ResourceType({name:"Items | ",id:"3",url:"items",parent_id:null,resource_id:""});
                  var sample4 = new ResourceType({name:"Explore |",url:"explore",id:"4",parent_id:null,resource_id:""});
                  var sample5 = new ResourceType({name:"France",url:"stores/france",id:"1_1",parent_id:"1",resource_id:""});
                  var sample6 = new ResourceType({name:"USA",id:"1_2",url:"stores/usa",parent_id:"1",resource_id:""});
                  var sample7 = new ResourceType({name:"Spain",id:"1_3",url:"stores/spain",parent_id:"1",resource_id:""});
                  var sample8 = new ResourceType({name:"Australia",id:"1_4",url:"stores/australia",parent_id:"1",resource_id:""});
                  var sample9 = new ResourceType({name:"Paris",id:"1_8",url:"stores/france/paris",parent_id:"1_1",resource_id:""});
                  var sample10 = new ResourceType({name:"Lyon",id:"1_9",url:"stores/france/lyon",parent_id:"1_1",resource_id:""});
                  var sample11 = new ResourceType({name:"Shoes",id:"3_9",url:"items/shoes",parent_id:"3",resource_id:"1"});
                  var sample12 = new ResourceType({name:"Jeans",id:"3_10",url:"items/jeans",parent_id:"3",resource_id:"2"});
                  var sample13 = new ResourceType({name:"Top",id:"3_11",url:"items/top",parent_id:"3",resource_id:"3"});
                  var sample14 = new ResourceType({name:"Bags",id:"3_12",url:"items/bags",parent_id:"3",resource_id:"4"});
                  var sample15 = new ResourceType({name:"Accessories",id:"3_13",url:"items/acessories",parent_id:"3",resource_id:"5"});

                  



                  this.add(sample0);
                  this.add(sample1);
                  this.add(sample2);
                  this.add(sample3);
                  this.add(sample4);
                  this.add(sample5);
                  this.add(sample6);
                  this.add(sample7);
                  this.add(sample8);
                  this.add(sample9);
                  this.add(sample10);
                  this.add(sample11);
                  this.add(sample12);
                  this.add(sample13);
                  this.add(sample14);
                  this.add(sample15);
                  
               } 
            });
            
            
    return ResourcesType;
});

