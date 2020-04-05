function popupCenter(url, width, height, name) {
  var left = (screen.width/2)-(width/2);
  var top = (screen.height/2)-(height/2);
  popupValue = "on";
  return window.open(url, name, "menubar=no,toolbar=no,status=no,width=500,height=700,toolbar=no,left=0,top=0"     );
 }
 
 $(document).ready(function(){
 $("a.signin-btn").click(function(e) {
 popupCenter($(this).attr("href"), $(this).attr("data-width"), $(this).attr("data-height"), "authPopup");
 e.stopPropagation(); return false;
 });
 
 
 if(window.opener && window.opener.popupValue === 'on') {
  delete window.opener.popupValue;
  window.opener.location.reload(true);
  window.close()
 }
 });