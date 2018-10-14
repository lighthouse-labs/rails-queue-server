// This helps fix a weird bug where the right side (.main-content)
// gets too width and stacks below left nav div, instead of staying to the right of it
// this occurs due to certain pre tags getting a tad bit too wide
// couldn't solve it with css no matter what I tried :(
// not sure why ... KV

$(document).on('turbolinks:load', function() {
  function prismWidthFixer(evt) {
    if ($('.main-content .activity-details').size() < 1) return;
    $('.main-content pre').hide();
    var width = $('.main-content').width();
    $('.main-content pre').width(width-40).show();
  }

  // only attach resize handler if necessary (prism pre tags exist)
  if ($('pre[class*="language-"]').size() > 0) {
    $(window).off('resize.prismfixer');
    $(window).on('resize.prismfixer', prismWidthFixer);
    prismWidthFixer();
  } else {
    $(window).off('resize.prismfixer');
  }

});