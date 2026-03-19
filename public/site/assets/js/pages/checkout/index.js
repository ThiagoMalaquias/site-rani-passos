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

function cc_format(value) {
    var v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '')
    var matches = v.match(/\d{4,16}/g);
    var match = matches && matches[0] || ''
    var parts = []

    for (i = 0, len = match.length; i < len; i += 4) {
        parts.push(match.substring(i, i + 4))
    }

    if (parts.length) {
        return parts.join(' ')
    } else {
        return value
    }
}

$('#cardNumber').on('keyup change', function () {
    $t = $(this);

    card_number = $(this).val();

    $('.credit-card-box .number').html(cc_format(card_number));

});

$('#cardHolder').on('keyup change', function () {
    $t = $(this);
    $('.credit-card-box .card-holder div').html($t.val());
});

$('#cardHolder').on('keyup change', function () {
    $t = $(this);
    $('.credit-card-box .card-holder div').html($t.val());
});

$('#cardExpirationMonth, #cardExpirationYear').change(function () {
    m = $('#cardExpirationMonth option').index($('#cardExpirationMonth option:selected'));
    m = (m < 10) ? '0' + m : m;
    y = $('#cardExpirationYear').val().substr(2, 2);
    $('.card-expiration-date div').html(m + '/' + y);
})

$('#cardCvv').on('focus', function () {
    $('.credit-card-box').addClass('hover');
}).on('blur', function () {
    $('.credit-card-box').removeClass('hover');
}).on('keyup change', function () {
    $('.ccv div').html($(this).val());
});

/* function getCreditCardType(accountNumber) {
    if (/^5[1-5]/.test(accountNumber)) {
        result = 'mastercard';
    } else if (/^4/.test(accountNumber)) {
        result = 'visa';
    } else if (/^(5018|5020|5038|6304|6759|676[1-3])/.test(accountNumber)) {
        result = 'maestro';
    } else {
        result = 'unknown'
    }
    console.log('teste')
    return result;
}

$('#input-cart-number').change(function () {
    console.log(getCreditCardType($(this).val()));
}) */