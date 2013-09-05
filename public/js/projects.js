/*jslint nomen: true, regexp: true */
/*global $, window, blueimp */

$(function () {
  'use strict';

  // Initialize the jQuery File Upload widget:
  $('#fileupload').fileupload({
    // Uncomment the following to send cross-domain cookies:
    //xhrFields: {withCredentials: true},
    url: '/documents/upload',
    //maxFileSize: 5000000,
    acceptFileTypes: /(\.|\/)(pdf|doc|docx|html|txt|csv|xls|xlsx)$/i
  });

  // Load existing files:
  $('#fileupload').addClass('fileupload-processing');
  $.ajax({
    // Uncomment the following to send cross-domain cookies:
    //xhrFields: {withCredentials: true},
    url: $('#fileupload').fileupload('option', 'url'),
    dataType: 'json',
    context: $('#fileupload')[0]
  }).always(function () {
    $(this).removeClass('fileupload-processing');
  }).done(function (result) {
    $(this).fileupload('option', 'done')
    .call(this, null, {result: result});
  }).fail(function(e, data) {
    console.error(data);
  });

  $('#new-project').submit(function(e) {
    e.preventDefault();

    // TODO validate project's name presence

    var data = $(this).serializeArray();
    var filenames = $.makeArray($('#fileupload .files .name span').map(function(i, e) { return $(e).text(); }));

    // TODO validate with a better error message than an alert
    if (filenames.length == 0) {
      alert("Debes subir al menos un documento");
      return false;
    }

    data.push({
      name: 'filenames',
      value: filenames
    });
    console.log(JSON.stringify(data));

    $.post('/projects/new', data, function(res) {
      // TODO redirect to /project/:id with a success flash message, or something like that
      alert(JSON.stringify(res));
    }).error(function() {
      alert("Ocurrió un error");
    });
  });

  $('#submit-btn').click(function() {
    $('#new-project').submit();
  });
});
