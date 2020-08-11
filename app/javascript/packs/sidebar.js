$(document).ready(function () {

  $('#sidebarCollapse').on('click', function () {
      $('#sidebar').toggleClass('active');
  });

  function openNav() {
    $("#mySidenav").animate({width: "320px"}, 400);
    $(".hamburger").animate({marginLeft: "275px"}, 400);
    $("#m_toggle").one("click", function(){
      closeNav()});
  }
  
  function closeNav() {
    $("#mySidenav").animate({width: "0"}, 400);
    $(".hamburger").animate({marginLeft: "-40px"}, 400)
    $(".hamburger").animate({marginLeft: "0"}, 700);
    
    $("#m_toggle").one("click", function(){ openNav()});
  }

  $("#m_toggle").one("click", function(){openNav()});
  $(".hamburger").on("click", function(){
    $(".hamburger").toggleClass("is-active");
  });

  function showNavItem() {
    $("#mySidenav").animate({top: "240px"}, 400);
    $(".hamburger").animate({top: "240px"}, 250);
    $(".navbar-toggler").one("click", function(){hideNavItem()});
  }
  
  function hideNavItem() {
    $("#mySidenav").animate({top: "60px"}, 400);
    $(".hamburger").animate({top: "60px"}, 400)
    
    $(".navbar-toggler").one("click", function(){ showNavItem()});
  }

  $(".navbar-toggler").one("click", function(){showNavItem()});

  $(window).on("resize", function(){
    if ($(window).width() >= 768) {  
      $("#mySidenav").animate({top: "60px"}, 400);
      $(".hamburger").animate({top: "60px"}, 400)
    }
  });
});