//= require jquery3
//= require bootstrap
//= require popper 
//= require jquery_ujs
//= require activestorage
//= require_tree


$(()=>$(".hide").fadeOut(4000));

$(document).unbind('keydown').bind('keydown', function (event) {
  if (event.keyCode === 8) {
      var doPrevent = true;
      var types = ["text", "password", "file", "search", "email", "number", "date", "color", "datetime", "datetime-local", "month", "range", "search", "tel", "time", "url", "week"];
      var d = $(event.srcElement || event.target);
      var disabled = d.prop("readonly") || d.prop("disabled");
      if (!disabled) {
          if (d[0].isContentEditable) {
              doPrevent = false;
          } else if (d.is("input")) {
              var type = d.attr("type");
              if (type) {
                  type = type.toLowerCase();
              }
              if (types.indexOf(type) > -1) {
                  doPrevent = false;
              }
          } else if (d.is("textarea")) {
              doPrevent = false;
          }
      }
      if (doPrevent) {
          event.preventDefault();
          return false;
      }
  }
}); 
// $(document).ready(function() {
  
//   $(".add-fields").click(function(event){
//     event.preventDefault();
//     time = new Date().getTime();
//     regexp = new RegExp($(this).data("id"), "g");
//     $(this).before($(this).data("fields").replace(regexp, time));
//   });
// });

// $(document).on("click",".remove-field", function(event){
//   event.preventDefault();
//   $(this).prev("input[type=hidden]").val("1");
//   $(this).closest('.subtask ').hide();
// });