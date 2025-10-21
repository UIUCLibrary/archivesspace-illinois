$(function () {
  // Generates the EAD ID field value based on other identifier fields in the resource form
  // Joins non-empty identifier fields with a dot (.) and removes whitespaces
  // Updates the ead_id field in real-time as the user types
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

  // Moves the finding_aid_filing_title field next to the title field
  // and synchronizes its value with the title field in real-time
  var initSortTitleField = function (scope) {
    $filingTitle = $('textarea[name="resource[finding_aid_filing_title]"]', scope);
    $title = $('textarea[name="resource[title]"]', scope);

    $title.parents('.form-group:first').after($filingTitle.parents('.form-group:first'));

    // set initial value of finding_aid_filing_title if empty
    if ($filingTitle.val().length === 0) {
      $filingTitle.val($title.val());
    }

    $title.on(
      'keyup',
      function (event) {
        // copy value to finding_aid_filing_title field
        $filingTitle.val($(event.target).val());
      }
    )
  }

  $(document).bind('loadedrecordform.aspace', function (event, $container) {
    initEadIdField($container);
    initSortTitleField($container);
  });
  initEadIdField();
  initSortTitleField();
});
