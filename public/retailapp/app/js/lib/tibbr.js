


current_user = null;

//CANNOT USE THE VARIBALE DEFINED IN BACKBONE JS BECAUSE THE TIBBR.js SCRIPT IS LOADED BEFORE
//Indeed, the script needs to be inizialize before the main Backbonejsto be able to resize TIB.parentApp container 
// when calling Home, Items ...
TIBBR_HOST = document.getElementById('tibbr_host').getAttribute('data-tibbr_host');
TIBBR_SITE = document.getElementById('tibbr_site').getAttribute('data-tibbr_site');

TIB.init({
            host:TIBBR_HOST+"/tibbr",
            tunnelUrl: TIBBR_SITE+"/retailapp/app/js/a/gadgets/pagebus/js/full/tunnel.html",
            renderInTibbr: true
 });
//console.log("avant oninit "+TIB.onInit().text());
TIB.onInit(function(){
});

function setAdjustHeight() {
    
    

                                          //  console.log("3 "+TIB.parentTibbr)

                          $.each(["show"], 

                         // $.each(["append","prepend","html","hide","remove","show", "addClass", "removeClass"], 
                              function(i,v){

                                var ext_f = $.fn[v];
                                $.fn[v] = function(){
                                if(window["dom_changed"]) {
                                  clearTimeout(window["dom_changed"]);
                                  window["dom_changed"] = null;
                                }
                                window["dom_changed"] = setTimeout(function(){
                                    try{
                                        var frame_height = $("#container").height()
                                        TIB.parentApp.setFrameHeight(frame_height);
                                    }catch(e){
                                      console.warn(e);
                                    }
                                }, "100")
                                return ext_f.apply( this, arguments );
                            };
                         });
                      }


TIB.onLogin(function(){
     current_user = TIB.currentUser;
 });
 
 


        

 
 


