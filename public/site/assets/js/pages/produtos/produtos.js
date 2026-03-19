$("select#ordem").on("change", (function () {
    $("form#formFilter").submit()
})), $(".slider-for").slick({
    slidesToShow: 1,
    slidesToScroll: 1,
    arrows: !1,
    fade: !0,
    asNavFor: ".slider-nav"
}), $(".slider-nav").slick({
    slidesToShow: 3,
    slidesToScroll: 1,
    asNavFor: ".slider-for",
    dots: !1,
    arrows: !0,
    verticalSwiping: !0,
    vertical: !0,
    focusOnSelect: !0
});