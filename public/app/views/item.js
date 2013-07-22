define([
  'jquery',
  'underscore',
  'backbone',
  'tibbr',
  'collections/items',
  'collections/images',
  'views/coverflow',
  'text!templates/item.html',
], function($,_,Backbone,Tibbr,ItemsCollection,ImagesCollection,CoverFlowView,itemTemplate){
    
    var ItemView = Backbone.View.extend({
        el: ".main-content",
        initialize: function(options){
            
           console.log(options);
           
            this.collection = new ItemsCollection(null,{type:options.type});
            console.log(options.index);
            this.collection.searchTerm = options.index;
            
            this.collection.bind("reset", this.render);
            this.collection.bind("change", this.render);


            this.pictures = new ImagesCollection;
            this.pictures.bind("change", this.displayCoverFlow);

             this.resource_gadget_base = "http://tibbr.localdomain.com/a/gadgets/resource_messages.html"
             var that = this;
            this.collection.fetch( {
                success:function (collection,response){
                    //console.log("RES "+JSON.stringify(collection));

                    that.render();
                    //that.pictures.searchTerm = "?item_id="+response[0].id;
                    that.pictures.searchTerm = "?item_id="+response.item[0].id;
                    that.updateCoverFlow();

                },
                error: function(){"ERROR"},         
                update:true,
            });
            

            //console.log("ALORS: "+this.collection);
        },
        parse: function(response) {
                console.log("Method parse");
                return response.results;
        },
        events: {
        "change": "itemSelectedOLD",
        "click .item_row" : "itemSelected",        
       // "mouseover #tib_container_item": "resizeTibbrFrameUp",
       // "mouseleave #tib_container_item": "resizeTibbrFrameDown"
        },
         render: function(){
            var that=this;
            var tmpl = _.template(itemTemplate)
       
             $(this.el).html(tmpl({gadget_url:this.gadget_url}))
            if (this.collection.length > 0){
            console.log("ENTER RENDER "+JSON.stringify(this.collection));
            
           _.each(this.collection.models[0].get("item"), function(curentItem,index){
                 //pourquoi $(this.el) ne marche pas  => OK parce que this pas défini, var that = this avant !!?
                 console.log("GET OBJECT:"+JSON.stringify(curentItem));
                 console.log("ssssss "+curentItem.id);
                // $('body').find("#select_items").append('<option id="#'+index+'" class="selectItem" value="'+curentItem.id+'">'+curentItem.reference+'</option>');
               console.log("******* "+JSON.stringify(that.collection.models[0]));

                 $('body').find("#test_truc").append('<tr class="item_row" id="'+curentItem.id+'"><td>'+curentItem.reference+"</td><td>"+curentItem.name+"</td><td>"+that.collection.models[0].get("resource").name+"</td></tr>")
             })
             
            }
             //this.pictures.searchTerm = "?item_id="+this.collection.models[0].id;
            // this.coverFlow = new CoverFlowView(null,{pictures:this.pictures});
            // this.coverFlow.setElement(this.$('#cover_div')).render();
           
            // this.updateCoverFlow();

            // this.coverFlow.setElement(this.$('#cover_div')).render();
             
             $("#tib_container_item").delay(100).animate({height:"50%"},600);
                $("#tibbr_wall").delay(100).fadeIn(1000);
                
                
             return this;
         },
         updateCoverFlow : function (){
     
             //var pictures = new ImagesCollection;
             //pictures.searchTerm = "?item_id="+this.collection.models[0].get("id");
             var that = this;
             this.pictures.fetch({
                
                 success: function(collection,response){
                     console.log("IMAGE RECEIVED:" +response);
                       that.displayCoverFlow(response);
                 },
            
             })
         },
         
         displayCoverFlow : function(pics){
             console.log("la: "+JSON.stringify(this.collection))
             this.coverFlow = new CoverFlowView(null,{pictures:pics});
           //  this.coverFlow.pics = pics;
             this.coverFlow.setElement(this.$('#cover_div')).render();
         },
         
          itemSelectedOLD: function(){
                console.log("OOOOOOO "+$("#select_items option:selected").text())
                console.log("Coll "+JSON.stringify(this.collection.models[0].get("item")));
                
                
                
              //  var selectItem = this.collection.models[0].get("item").models.find(function(item){
              //      console.log("=========================DBA: "+JSON.stringify(item));
              //      console.log("truc selectionne:"+$("#select_items option:selected").text());
                    
              //      return item.get('reference') === $("#select_items option:selected").text();
               // });
               var selectItem = $.grep(this.collection.models[0].get("item"), function(e){ 
                    
                    return e.reference == $("#select_items option:selected").text(); 
                    });
                console.log("sqsq "+JSON.stringify(selectItem));
                 this.pictures.searchTerm="?item_id="+selectItem[0].id;
                 this.updateCoverFlow();

                //this.coverFlow = new CoverFlowView(null,{pictures:selectItem.get("pictures")});
                //this.coverFlow.setElement(this.$('#cover_div')).render();

          },
           resizeTibbrFrameUp: function(){
          
              $(this.el).find('#tib_container_item').animate({height:"80%"},600);

                
           },
           resizeTibbrFrameDown: function (){
                 $(this.el).find('#tib_container_item').animate({height:"50%"},600);

           },
           
           itemSelected : function(e){
             console.log($(e.target).parent()[0].id)
             
             var selectItem = $.grep(this.collection.models[0].get("item"), function(elem){ 
                    
                    return elem.id == $(e.target).parent()[0].id; 
                    });
                console.log("sqsq "+JSON.stringify(selectItem));
                 this.pictures.searchTerm="?item_id="+selectItem[0].id;
                 this.url_gagdet_item = this.resource_gadget_base+ '?client_id=75&type=ad:item&key='+selectItem[0].tibbr_key
                 
                 console.log("FFSFFFF "+this.url_gagdet_item)
                 $(this.el).find("#tibbr_wall").attr("src",this.url_gagdet_item)
                 this.updateCoverFlow();
             
             
           }
        
    })
    
    return ItemView
    
})


