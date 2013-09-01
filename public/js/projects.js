/*jslint nomen: true, regexp: true */
/*global $, window, blueimp */

$(function () {
  'use strict';

  // Initialize the jQuery File Upload widget:
  $('#fileupload').fileupload({
    // Uncomment the following to send cross-domain cookies:
    //xhrFields: {withCredentials: true},
    url: '/documents/new',
    //maxFileSize: 5000000,
    acceptFileTypes: /(\.|\/)(pdf|doc|xls)$/i
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
    // FIXME Upload files (if any) before submitting
    //$('#fileupload').submit();
  });

  $('#submit-btn').click(function() {
    console.log('submit');
    $('#new-project').submit();
  });
});
