# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->

  $(document).bind "ajaxSuccess", "form.new_wishlist_form", (event, xhr, settings) ->
    $('#new_wishlist_modal').modal 'hide'
    window.location.reload(false);

  $(document).bind "ajaxError", "form.new_wishlist_form", (event, jqxhr, settings, exception) ->
    $new_wishlist_form = $(event.data)
    $error_container = $("#error_explanation", $new_wishlist_form)
    $error_container_ul = $("ul", $error_container)
    $error_container.show()  if $error_container.is(":hidden")
    $.each jqxhr.responseJSON, (index, message) ->
      $("<li>").html(message).appendTo $error_container_ul