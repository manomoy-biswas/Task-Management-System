$(document).ready(function(){
  
  //activating the sidenav menu item
  var path = window.location.pathname;
  var page = path.substring(path.lastIndexOf("/") + 1);
  var page2 = path.substring(path.substring(0, path.lastIndexOf("/")).lastIndexOf("/") + 1, path.lastIndexOf("/") );
  if (page == "overview"){
    $(".menu-1").addClass("active");
  }
  else if (page == "users"){
    $(".menu-2").addClass("active");
  }
  else if (page == "categories"){
    $(".menu-3").addClass("active");
  }
  else if (page == "tasks"){
    $(".menu-4").addClass("active");
  }
  else if (page == "user_assigned_task"){
    $(".menu-5").addClass("active");
  }
  else if (page == "approved_task"){
    $(".menu-6").addClass("active");
  }
  else if (page == ""){
    $(".menu-6").addClass("active");
  }
  else if (page2 == "users"){
    $(".menu-7").addClass("active");
  }


  // display date time
  setInterval(function(){
		var today = new Date();
		var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	  var I = today.getHours();
	  var M = today.getMinutes();
		var S = today.getSeconds();
		var d = today.getDate();
		var b = today.getMonth();
		var Y = today.getFullYear();
		
	  if(S<10){
			S = "0"+S;
	  }
	  if (M < 10) {
			M = "0" + M;
	  }
	  if (I > 12 && I<=24){ 
		  I -= 12; 
		  p = "PM"
	  }
	  else if (I >= 1 && I< 12){ 
		  I = "0" + I;
		  p = "AM"
	  }
	  else{p = "PM"}
    $(".timer").text(d + " " + monthNames[b] + ", " + Y + " " + I + ":" + M + ":" + S + " " + p);
  }, 1000);
  
  //Counter animation in overview page
  $('.counter').each(function () {
    var $this = $(this);
    jQuery({ Counter: 0 }).animate({ Counter: $this.text() }, {
      duration: 1000,
      easing: 'swing',
      step: function () {
        $this.text(Math.ceil(this.Counter));
      }
    });
  });
});