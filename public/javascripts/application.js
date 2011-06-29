$(document).ready(function() {
  $('.child').hide();

  $('.parent th').each(function(index, node) {
    var toggle = $(document.createElement('a'));
    toggle.attr({ href: '#' });
    toggle.html('+');
    toggle.addClass('toggle');
    toggle.click(function(event) {
      var parentId = $(this).parents('tr.parent').attr('id');
      if (parentId) {
        $('tr.child.' + parentId).toggle();
      };

      event.stopPropagation();
      return false;
    });
    $(node).prepend(toggle);
  });
});

