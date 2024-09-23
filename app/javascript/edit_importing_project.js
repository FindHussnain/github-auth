$(document).ready(function() {
  $('.restricted-input').on('input', function() {
    if ($(this).val().length > 3) {
      $(this).val($(this).val().slice(0, 3));
    }
  });
});
