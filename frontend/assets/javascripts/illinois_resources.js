$(function () {
  // Generates the EAD ID field value based on other identifier fields in the resource form
  // Joins non-empty identifier fields with a dot (.) and removes whitespaces
  // Updates the ead_id field in real-time as the user types
  var initEadIdField = function (scope) {
    scope = scope || $(document.body);
    let $eadIdInput = $('input[name="resource[ead_id]"]', scope);
    if ($eadIdInput?.length > 0) {
      //make ead_id field readonly
      $eadIdInput.attr('readonly', 'readonly');
      // listen for changes in identifier fields
      $('form:not(.navbar-form) .identifier-fields', scope)
        .off('keyup.resourceEadId')
        .on('keyup.resourceEadId', ':input', function (event) {
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
        });
    }
  };

  // Moves the finding_aid_filing_title field next to the title field
  // and synchronizes its value with the title field in real-time
  var initTitleFields = function (scope) {
    let $findingAidFilingTitle = $('textarea[name="resource[finding_aid_filing_title]"]', scope);
    let $findingAidTitle = $('textarea[name="resource[finding_aid_title]"]', scope);
    let $title = $('textarea[name="resource[title]"]', scope);
    let $eventScope = $findingAidTitle.closest('form');
    if ($eventScope.length === 0) {
      $eventScope = scope || $(document.body);
    }

    // move the finding_aid_filing_title field next to the title field
    $title.parents('.form-group:first').after($findingAidFilingTitle.parents('.form-group:first'));

    // make finding_aid_title field readonly and hide its CodeMirror editor
    $findingAidTitle.attr('readonly', 'readonly');
    $findingAidTitle.css('display', 'block').addClass('form-control');
    $findingAidTitle.siblings('.CodeMirror').css('display', 'none');

    // function to update the finding_aid_title field based on title and creation date
    var updateFindingAidTitle = function () {
      let $dates = $('.date-container', scope);
      let creationDate = null;
      $dates.each(function () {
        let $date = $(this);
        let label = $('[name$="[label]"]', $date).val();
        if (label === 'creation' && !creationDate) {
          let endDate = $('[name$="[end]"]', $date).val() || '';
          creationDate = $('[name$="[expression]"]', $date).val() || '';

          if (!creationDate) {
            creationDate = $('[name$="[begin]"]', $date).val() || '';
            if (endDate) {
              creationDate += (creationDate ? '-' : '') + endDate;
            }
          }
        }
      });
      $findingAidTitle.val('Guide to the ' + $title.val() + (creationDate ? ', ' + creationDate : ''));
    };

    // set initial value of finding_aid_filing_title if empty
    if ($findingAidFilingTitle.val()?.length === 0) {
      $findingAidFilingTitle.val($title.val());
    }

    // set initial value of finding_aid_title based if empty
    if ($findingAidTitle.val()?.length === 0) {
      updateFindingAidTitle();
    }

    $title.off('keyup.resourceTitleSync').on('keyup.resourceTitleSync', function (event) {
      // copy value to finding_aid_filing_title field
      $findingAidFilingTitle.val($(event.target).val());
      updateFindingAidTitle();
    });

    $eventScope
      .off('keyup.resourceTitleSync', '.date-container [name$="[expression]"]')
      .on('keyup.resourceTitleSync', '.date-container [name$="[expression]"]', updateFindingAidTitle);

    $eventScope
      .off('change.resourceTitleSync', '.date-container [name$="[label]"], .date-container [name$="[date_type]"], .date-container [name$="[begin]"], .date-container [name$="[end]"]')
      .on('change.resourceTitleSync', '.date-container [name$="[label]"], .date-container [name$="[date_type]"], .date-container [name$="[begin]"], .date-container [name$="[end]"]', updateFindingAidTitle);
  }

  $(document).off('loadedrecordform.aspace.illinoisResources').on('loadedrecordform.aspace.illinoisResources', function (event, $container) {
    initEadIdField($container);
    initTitleFields($container);
  });
  initEadIdField();
  initTitleFields();
});
