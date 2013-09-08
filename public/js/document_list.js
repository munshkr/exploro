/*jslint nomen: true, regexp: true */
/*global $, window, blueimp */

'use strict';

function setDocumentStateAutoUpdate(ids) {
  setInterval(function() {
    $.getJSON('/api/documents/state?ids=' + ids.join(','), function(res) {
      var $table = $('table.documents');
      $.each(res, function(i, e) {
        var $doc = $table.find('tr.document[data-id="' + e.id + '"]');
        $doc.find('.state').text(e.state === null ? '' : e.state);
        $doc.find('.percentage').text(e.percentage + ' %');

        var $tools = $table.find('tr.tools[data-id="' + e.id + '"]');
        if (e.percentage < 100) {
          $tools.find('.progress').removeClass('hidden');
          $tools.find('.progress-bar')
            .attr('aria-valuenow', e.percentage)
            .css('width', e.percentage + '%');
        } else {
          $tools.find('.progress').addClass('hidden');
        }
      });
    });
  }, 1000);
};
