current_user = null;
console.log("Enter tibbr.js");
TIB.init({
            host: "tibbr.localdomain.com/tibbr",
            tunnelUrl: "http://localhost:8383/Sample1/app/js/a/gadgets/pagebus/js/full/tunnel.html"
 });
//console.log("avant oninit "+TIB.onInit().text());
TIB.onInit(function(){
     console.log('enter onInit' );
     console.log('out onInit');
});



TIB.onLogin(function(){
     console.log('enter onLogin');
     current_user = TIB.currentUser;
     console.log('ssssdd '+current_user.display_name);
     document.getElementById('user_connected').innerHTML ="Welcome "+ current_user.display_name;
 });
 
 
 

        

 
 


