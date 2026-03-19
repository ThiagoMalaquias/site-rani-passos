$(document).ready(function () {
    $("#banner-responsive").slick({
        dots: false,
        infinite: !0,
        speed: 250,
        autoplay: true,
        autoplaySpeed: 6000,
        slidesToShow: 1,
        slidesToScroll: 1,
        responsive: [{
            breakpoint: 1024,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1,
                infinite: !0,
                dots: !0
            }
        }, {
            breakpoint: 600,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1
            }
        }, {
            breakpoint: 480,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1
            }
        }]
    }), $(".dep-slider").slick({
        dots: false,
        infinite: !0,
        speed: 250,
        slidesToShow: 1,
        slidesToScroll: 1,
        responsive: [{
            breakpoint: 1200,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1,
                infinite: !0,
                dots: !0
            }
        }, {
            breakpoint: 769,
            settings: {
                arrows: !1,
                slidesToShow: 2,
                slidesToScroll: 1
            }
        }, {
            breakpoint: 500,
            settings: {
                arrows: !1,
                slidesToShow: 1,
                slidesToScroll: 1
            }
        }]
    })

    $("#banner-responsivemobile").slick({
        dots: false,
        infinite: !0,
        speed: 250,
        slidesToShow: 1,
        autoplay: true,
        autoplaySpeed: 6000,
        slidesToScroll: 1,
        responsive: [{
            breakpoint: 1024,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1,
                infinite: !0,
                dots: !0
            }
        }, {
            breakpoint: 600,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1
            }
        }, {
            breakpoint: 480,
            settings: {
                slidesToShow: 1,
                slidesToScroll: 1
            }
        }]
    });

    $(".instructors-carousel").slick({
        dots: false,
        infinite: true,
        speed: 500,
        arrows: true,
        slidesToShow: 1,
        slidesToScroll: 1,
        autoplay: true,
        autoplaySpeed: 5000,
        fade: true,
        cssEase: 'linear',
        responsive: [{
            breakpoint: 768,
            settings: {
                arrows: false,
                dots: true
            }
        }]
    });
})