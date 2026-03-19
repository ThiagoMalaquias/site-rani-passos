$(document).on("scroll", scroll);

menu = $('nav#menus a');
menu.filter(':first').addClass('aktif');

menu.on('click', function () {

    $(document).off("scroll");
    var id = $(this).attr('href'),
        target = this.hash;
    menu.removeClass('aktif');
    $(this).addClass('aktif');
    $('html, body').animate({
        scrollTop: $(id).offset().top
    }, {

        duration: 500,
        complete: function () {
            $('.icerik').css('background', 'transparent');
            $(id).css('background', '#FFF');
            $(document).on("scroll", scroll);
        }
    });
    return false;
});

var offset = $("#sideprogress").offset();
var topPadding = 15;
$(window).scroll(function () {
    if ($(window).scrollTop() > offset.top) {
        $("#sideprogress").stop().animate({
            marginTop: $(window).scrollTop() - offset.top + topPadding
        });
    } else {
        $("#sideprogress").stop().animate({
            marginTop: 0
        });
    };
});

function scroll(event) {

    var scrollPos = $(document).scrollTop();
    menu.each(function () {

        var currLink = $(this);
        var refElement = $(currLink.attr("href"));
        if (refElement.position().top <= scrollPos && refElement.position().top + refElement.height() > scrollPos) {
            menu.removeClass("aktif");
            currLink.addClass("aktif");
        }
    });

}