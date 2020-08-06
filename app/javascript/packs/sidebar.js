$(document).ready(function () {

  $('#sidebarCollapse').on('click', function () {
      $('#sidebar').toggleClass('active');
  });

  function openNav() {
    $(".copyright").animate({marginLeft: "320px"}, 400);
    $("#mySidenav").animate({width: "320px"}, 400);
    $(".hamburger").animate({marginLeft: "275px"}, 400);
    $("#m_toggle").one("click", function(){
      closeNav()});
  }
  
  function closeNav() {
    $("#mySidenav").animate({width: "0"}, 400);
    $(".copyright").animate({marginLeft: "0"}, 400);
    $(".hamburger").animate({marginLeft: "-40px"}, 400)
    $(".hamburger").animate({marginLeft: "0"}, 700);
    
    $("#m_toggle").one("click", function(){ openNav()});
  }

  $("#m_toggle").one("click", function(){openNav()});
  $(".hamburger").on("click", function(){
    $(".hamburger").toggleClass("is-active");
  });
});