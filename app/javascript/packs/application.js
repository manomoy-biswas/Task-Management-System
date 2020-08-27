require("jquery")
require("@rails/ujs").start()
require("turbolinks")
require("@rails/activestorage").start()
require("channels")
require("bootstrap")
require("packs/tasks")
require("packs/sidebar")
require("packs/home")

//fade out the flash message with timer
$(()=>$(".hide").fadeOut(4000));
// prevent user from going back using backspace button
$(document).unbind('keydown').bind('keydown', function (event) {
  if (event.keyCode === 8) {
    let doPrevent = true;
    const types = ["text", "password", "file", "search", "email", "number", "date", "color", "datetime", "datetime-local", "month", "range", "search", "tel", "time", "url", "week"];
    const d = $(event.target || null );
    const disabled = d.prop("readonly") || d.prop("disabled");
    if (!disabled) {
      if (d[0].isContentEditable) {
          oPrevent = false;
      } 
      else if (d.is("input")) {
        let type = d.attr("type");
        if (type) {
          type = type.toLowerCase();
        }
        if (types.indexOf(type) > -1) {
          doPrevent = false;
        }
      } 
      else if (d.is("textarea")) {
        doPrevent = false;
      }
    }
    if (doPrevent) {
        event.preventDefault();
        return false;
    }
  }
});

$(document).ready(function(){
  //submitting dorm on change event
  $('#file-input').on('change', function() { 
    $(this.form).submit(); 
  });

  $('#filter_input, #sort_input').on('change', function() { 
    $(this.form).submit(); 
  });
  
  //formating the datepicjer field 
  $('#datepicker1').datetimepicker({
    format: "DD/MM/YYYY"
  });

  //only number input in mobile number field
  $("#user_phone").keypress(function(event){
    var key = event.charCode
    if ((event.location == 3 && key >= 96 && key <= 105) || (key >= 48 && key <= 57) || key == 8) {}
    else{ event.preventDefault(); }
  });
});
  
