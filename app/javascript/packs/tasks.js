$(document).ready(function() {
  $(".add-fields").click(function(event){
    event.preventDefault();
      let time = new Date().getTime();
      let regexp = new RegExp($(this).data("id"), "g");
      $(this).after($(this).data("fields").replace(regexp, time));
  });

  $('#datetimepicker1').datetimepicker({
    sideBySide: true,
    format: "DD MMM, YYYY LT",
    icons: {
      up: "fa fa-angle-up",
      down: "fa fa-angle-down",
      previous: 'fa fa-angle-double-left',
      next: 'fa fa-angle-double-right',
    }
  });
});

$(document).on("click",".remove-field", function(event){
  event.preventDefault();
  $(this).prev("input[type=hidden]").val("1");
  $(this).closest('.subtask ').hide();
});