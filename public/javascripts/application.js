$(document).ready(function() {
  $('.child').hide();

  $('.parent th').each(function(index, node) {
    var node = $(node);

    // Create a link to replace the existing content of the th
    var toggle = $(document.createElement('a'));
    toggle.attr({ href: '#' });
    toggle.html(node.html());
    toggle.addClass('toggle');

    // Hook up a click event to the link that toggles display of child accounts
    toggle.click(function(event) {
      var parentId = $(this).parents('tr.parent').toggleClass('expanded').attr('id');
      if (parentId) {
        $('tr.child.' + parentId).toggle();
      };

      event.stopPropagation();
      return false;
    });
    $(node).html(toggle);
  });

  $('#tax_payment').bind('change', function(event) {
    value = $(event.currentTarget).val();
    if (value) {
      value = value.replace(/[^0-9]/g, '');
      $(event.currentTarget).val(value);
    };
  });
});

