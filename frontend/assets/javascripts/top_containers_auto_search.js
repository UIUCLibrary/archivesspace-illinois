function waitForResourceLinker(callback) {
  var form = document.getElementById('bulk_operation_form');

  function ready() {
    return form.querySelector(
      'input[name="collection_resource[ref]"]'
    ) &&
    form.querySelector(
      'input[name="collection_resource[_resolved]"]'
    );
  }

  if (ready()) {
    callback();
    return;
  }

  var observer = new MutationObserver(function () {
    if (ready()) {
      observer.disconnect();
      callback();
    }
  });

  observer.observe(form, {
    childList: true,
    subtree: true
  });
}

$(window).on('load', function () {
  if (new URLSearchParams(window.location.search).get('autosearch') === 'true') {
    waitForResourceLinker(function () {
      $('#bulk_operation_form').trigger('submit');
    });
  }
});