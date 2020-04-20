$(document).ready(function() {
  $(".add-fields").click(function(event){
    event.preventDefault();
      let time = new Date().getTime();
      let regexp = new RegExp($(this).data("id"), "g");
      $(this).after($(this).data("fields").replace(regexp, time));
  });
});

$(document).on("click",".remove-field", function(event){
  event.preventDefault();
  $(this).prev("input[type=hidden]").val("1");
  $(this).closest('.subtask ').hide();
});