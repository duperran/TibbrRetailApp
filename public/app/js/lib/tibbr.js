


current_user = null;

//CANNOT USE THE VARIBALE DEFINED IN BACKBONE JS BECAUSE THE TIBBR.js SCRIPT IS LOADED BEFORE
//Indeed, the script needs to be inizialize before the main Backbonejsto be able to resize TIB.parentApp container 
// when calling Home, Items ...
RAILS_RELATIVE_URL_ROOT = document.getElementById('rails').getAttribute('data-relative_url_root');

console.log("Enter tibbr.js"+RAILS_RELATIVE_URL_ROOT);
TIB.init({
            host: RAILS_RELATIVE_URL_ROOT+"/tibbr",
            tunnelUrl: "http://"+RAILS_RELATIVE_URL_ROOT+"/app/js/a/gadgets/pagebus/js/full/tunnel.html",
            renderInTibbr: true
 });
//console.log("avant oninit "+TIB.onInit().text());
TIB.onInit(function(){
     console.log('enter onInit' );
     console.log('out onInit');
     console.log(TIB.parentApp);
     //setAdjustHeight();

});

function setAdjustHeight() {
    
    

                                          //  console.log("3 "+TIB.parentTibbr)

                           console.log("RESIZe 0")
                          $.each(["show"], 

                         // $.each(["append","prepend","html","hide","remove","show", "addClass", "removeClass"], 
                              function(i,v){
                                 console.log("RESIZe 1")

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
     console.log('enter onLogin');
     current_user = TIB.currentUser;
 });
 
 


        

 
 


