// Generates the EAD ID field value based on other identifier fields in the resource form
// Joins non-empty identifier fields with a dot (.) and removes whitespaces
// Updates the ead_id field in real-time as the user types
$(function () {
  var initEadIdField = function (scope) {
    scope = scope || $(document.body);
    $eadIdInput = $('input[name="resource[ead_id]"]', scope)
    if ($eadIdInput.length > 0) {
      //make ead_id field readonly
      $eadIdInput.attr('readonly', 'readonly');
      // listen for changes in identifier fields
      $('form:not(.navbar-form) .identifier-fields', scope).on(
        'keyup',
        ':input',
        function (event) {
          // copy value inputs to ead_id field
          var eadId = '';
          $(event.target)
            .parents('.identifier-fields:first')
            .find(':input')
            .each(function () {
              if ($(this).val().length > 0) {
                if (eadId.length > 0) {
                  eadId += '.';
                }
                eadId += $(this).val().replace(/\s+/g, '');
              }
            });
          $eadIdInput.val(eadId);
        }
      );
    }
  };
  $(document).bind('loadedrecordform.aspace', function (event, $container) {
    initEadIdField($container);
  });
  initEadIdField();
});
