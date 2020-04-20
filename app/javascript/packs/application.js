// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
require("jquery")
require("@rails/ujs").start()
require("turbolinks")
require("@rails/activestorage").start()
require("channels")
require("bootstrap")
require("packs/tasks")

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "bootstrap"


$(()=>$(".hide").fadeOut(4000));

$(document).unbind('keydown').bind('keydown', function (event) {
  if (event.keyCode === 8) {
      let doPrevent = true;
      const types = ["text", "password", "file", "search", "email", "number", "date", "color", "datetime", "datetime-local", "month", "range", "search", "tel", "time", "url", "week"];
      const d = $(event.target || null );
      const disabled = d.prop("readonly") || d.prop("disabled");
      if (!disabled) {
          if (d[0].isContentEditable) {
              doPrevent = false;
          } else if (d.is("input")) {
              let type = d.attr("type");
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
//     $(this).before($(this).data("fields").replace(regexp, time)).html(z);
//   });

//   $("#priority").on("change", function() {
//     var value = $(this).val().toLowerCase();
//     $("#task_table tr").filter(function() {
//       $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
//     });
//   });
// });
  
// $(document).on("click",".remove-field", function(event){
//   event.preventDefault();
//   $(this).prev("input[type=hidden]").val("1");
//   $(this).closest('.subtask ').hide();
// });
  
