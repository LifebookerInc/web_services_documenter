function showHide(dom, duration) {
  duration = duration || 300
  if($(dom).height()!=0) {
    $(dom).data('height', $(dom).height());
    $(dom).animate({height: 0},duration,'swing', function() {
      $(dom).hide(); //css('visibility', 'hidden');
    })
  } else {
    $(dom).show(); //css('visibility', 'visible');
    $(dom).animate({height: $(dom).data('height')},duration,'swing');
  }
}

$(document).ready(function() {
  $("h2").click(function() {
    showHide($(this).next())
  });
  $("h2").each(function(i,el){
    showHide($(el).next(), 1)
  });
  $("body").css("visibility", "visible")
})