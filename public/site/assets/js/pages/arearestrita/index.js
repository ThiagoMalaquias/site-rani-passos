
if (window.performance) {

    if (performance.navigation.type != 1) {

        str = document.referrer;
        if (str.indexOf("arearestrita") == -1) {
            if (window.location.href !== document.referrer) {
                localStorage.removeItem('tab_act');
            }
        }

    }

}

tabAct = localStorage.getItem('tab_act');

if (tabAct) {

    $('div[id^="tab"].active').hide().removeClass("active");

    $('ul#tabs li.active').removeClass('active');

    $("ul#tabs li a[href='" + tabAct + "']").parent().addClass('active')

    $('div' + tabAct).show();
    $('div' + tabAct).addClass('active');

}

$('div[id^="tab"]').find('.active').show();

$('ul#tabs li a').on('click', (e) => {
    e.preventDefault();


    $('ul#tabs li.active').removeClass('active');
    $('div[id^="tab"].active').removeClass('active').hide();

    let menu = $(e.target);
    menu.parent().addClass('active');

    let tab = menu.attr('href');

    $('div' + tab).fadeIn('slow');
    $('div' + tab).addClass('active');

    localStorage.setItem('tab_act', $('ul#tabs li.active a').attr('href'));

});

var SPMaskBehavior = function (val) {
    return 11 === val.replace(/\D/g, "").length ? "(00) 00000-0000" : "(00) 0000-00009"
},
    spOptions = {
        onKeyPress: function (val, e, field, options) {
            field.mask(SPMaskBehavior.apply({}, arguments), options)
        }
    };
    
$("#use_telefone").mask(SPMaskBehavior, spOptions);
$('#add_cep').mask('00000-000');
$('#use_cpf').mask('000.000.000-00', { reverse: true });

function checkCForm(id) {
    return $(id).validate().checkForm()
}

function validateForm() {
    checkCForm("form#changePassForm") ? $("button#btnChangePass").prop("disabled", 0) : $("button#btnChangePass").prop("disabled", 1)
}
$("form#changePassForm").validate({
    onkeyup: function (element) {
        $(element).valid(), validateForm()
    },
    errorClass: "is-invalid",
    validClass: "is-valid",
    rules: {
        password: {
            required: !0,
        },
        new_password: {
            required: !0,
            minlength: 8,
            maxlength: 30
        },
        new_password_confirm: {
            required: !0,
            equalTo: "#new_password"
        }
    },
    messages: {
        password: {
            required: "Digite a sua senha"
        },
        new_password: {
            required: "Informe uma nova senha",
            minlength: "Sua nova senha deve ter no minimo 8 caracteres",
            maxlength: "Sua nova senha pode ter no máximo 30 caracteres"
        },
        new_password_confirm: {
            required: "Confirme sua senha",
            equalTo: "As senhas não conferem"
        }
    },
    errorPlacement: function (error, element) {
        error.appendTo(element.siblings("div.invalid-feedback"))
    }
});

$("form#loginForm").validate({
    onkeyup: function (element) {
        $(element).valid()
    },
    errorClass: "is-invalid",
    rules: {
        email: {
            email: !0,
        }
    },
    messages: {
        email: {
            email: "Email Inválido"
        }
    },
    errorPlacement: function (error, element) {
        error.appendTo(element.siblings("div.invalid-feedback"))
    }
});

$('select#selectAno').on('change', () => {

    $('form#formFilterOrders').submit();

});

let tabMes = $('div#tab_1_2 ul#pills-tab li a.active').data('mes');

if (!tabMes) {
    ativar = $('ul#pills-tab li:last-child a');

    ativar.addClass('active');

    tab = ativar.data('mes');

    $('div#pills-' + tab).addClass('active');

}