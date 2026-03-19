var checkout = new DirectCheckout('DA7A128EEE2DE8E0211CE58DE35E145CB565954A1078B19419577F299B778E87', false); //development
//var checkout = new DirectCheckout('20323048689A4EBEF0B19062D6557828D8DC6CACFAF7CC870005D07775AA7BE32EBED471CC71C429'); //production

jQuery.validator.addMethod("cpf", function (value, element) {

    cpf = value.replace(/[^\d]+/g, '');
    if (cpf == '') return false;
    // Elimina CPFs invalidos conhecidos	
    if (cpf.length != 11 ||
        cpf == "00000000000" ||
        cpf == "11111111111" ||
        cpf == "22222222222" ||
        cpf == "33333333333" ||
        cpf == "44444444444" ||
        cpf == "55555555555" ||
        cpf == "66666666666" ||
        cpf == "77777777777" ||
        cpf == "88888888888" ||
        cpf == "99999999999")
        return false;
    // Valida 1o digito	
    add = 0;
    for (i = 0; i < 9; i++)
        add += parseInt(cpf.charAt(i)) * (10 - i);
    rev = 11 - (add % 11);
    if (rev == 10 || rev == 11)
        rev = 0;
    if (rev != parseInt(cpf.charAt(9)))
        return false;
    // Valida 2o digito	
    add = 0;
    for (i = 0; i < 10; i++)
        add += parseInt(cpf.charAt(i)) * (11 - i);
    rev = 11 - (add % 11);
    if (rev == 10 || rev == 11)
        rev = 0;
    if (rev != parseInt(cpf.charAt(10)))
        return false;
    return true;

}, "CPF inválido");

jQuery.validator.addMethod("creditCardJuno", function (value, element) {

    return this.optional(element) || checkout.isValidCardNumber(value);

}, "Cartão inválido");

jQuery.validator.addMethod("validSecurityCode", function (value, element, param) {

    var target = $(param).val();

    return checkout.isValidSecurityCode(target.replace(/\s/g, ''), value);

}, "Código de Segurança inválido");

jQuery.validator.addMethod("validExpireDate", function (value, element, param) {

    var target = $(param);
    return checkout.isValidExpireDate(target.val(), value); //mes

}, "Data de validade inválida");

function checkCForm(id) {
    return $(id).validate().checkForm()
}

function validateFormRegister() {
    checkCForm("form#formpagamento") && grecaptcha.getResponse() ? $("button#formpagamento").prop("disabled", 0) : $("button#formpagamento").prop("disabled", 1)
}

var car_validate = $("form#formpagamento").submit(function (e) {
    e.preventDefault();
}).validate({
    onsubmit: function (element) {
        checkCForm("form#formpagamento")
    },
    onfocusout: false,
    errorClass: "is-invalid",
    rules: {
        installments: {
            required: !0
        },
        cardNumber: {
            required: !0,
            minlength: 19,
            creditCardJuno: !0
        },
        cardHolder: {
            required: !0,
            minlength: 3,
        },
        useCardCpf: {
            required: !0,
            minlength: 14,
            maxlength: 14,
            cpf: !0
        },
        cardExpirationMonth: {
            required: !0
        },
        cardExpirationYear: {
            required: !0,
            validExpireDate: "#cardExpirationMonth"
        },
        cardCvv: {
            required: !0,
            minlength: 3,
            maxlength: 3,
            digits: !0,
            validSecurityCode: "#cardNumber"
        }
    },
    messages: {
        installments: {
            required: "Informe quantas parcelas"
        },
        cardNumber: {
            required: "Digite o numero do cartão",
            minlength: "Digite o numero do cartão",
            creditCardJuno: "Cartão inválido",
        },
        cardHolder: {
            required: "Digite o nome do titular do cartão",
            minlength: "Digite o nome do titular do cartão"
        },
        useCardCpf: {
            required: "Digite o cpf do titular do cartão",
            minlength: "Digite o cpf do titular do cartão",
            maxlength: "Digite o cpf do titular do cartão",
            cpf: "CPF inválido"
        },
        cardExpirationMonth: {
            required: "Escolha o mês de validade",
        },
        cardExpirationYear: {
            required: "Escolha o ano de validade",
            validExpireDate: "Data de válidade inválida"
        },
        cardCvv: {
            required: "Digite o CVV",
            minlength: "Digite o CVV",
            maxlength: "Digite o CVV",
            digits: "Digite o CVV",
            validSecurityCode: "CVV inválido"
        }
    },
    errorPlacement: function (error, element) {

        error.appendTo(element.siblings("div.invalid-feedback"))

    },
    submitHandler: function (form) {
        var btnForm = $("form#formpagamento").find('button');
        var btnTextOld = btnForm.html();

        let cardData = {
            cardNumber: $('#cardNumber').val().replace(/\s/g, ''),
            holderName: $('#cardHolder').val(),
            securityCode: $('#cardCvv').val(),
            expirationMonth: $('#cardExpirationMonth').val(),
            expirationYear: $('#cardExpirationYear').val()
        };

        var erro = "";

        let cardValidated = checkout.isValidCardData(cardData, function (error) {
            erro = error;
        });

        if (cardValidated) {

            checkout.getCardHash(cardData, function (cardHash) {

                var formData = new FormData();
                formData.append("cardHash", cardHash);
                formData.append("installments", $('#installments').val());
                formData.append(CSRFTOKEN, CSRFHASH);
                formData.append('curso', curso);
                formData.append('cpf', $('#useCardCpf').val());

                $.ajax({
                    url: "checkout/pagar",
                    type: 'POST',
                    data: formData,
                    dataType: 'JSON',
                    processData: false,
                    contentType: false,
                    beforeSend: function () {
                        btnForm.prop('disabled', 1);
                        btnForm.html('<i class="fas fa-sync fa-spin"></i>');
                    },
                    success: function (response) {

                        if (response.status_code != 200 && response.status_code != 204) {
                            Swal.fire(
                                response.status_code,
                                response.reason_phrase,
                                'error'
                            )
                        } else {

                            Swal.fire({
                                title: 'Pagamento Aprovado!',
                                text: "Compra efetuada com sucesso!",
                                icon: 'success',
                                showCancelButton: false,
                                confirmButtonColor: '#3085d6',
                                confirmButtonText: 'OK',
                                allowOutsideClick: false,
                                allowEscapeKey: false,
                                allowEnterKey: false
                            }).then((result) => {

                                Swal.fire({
                                    title: 'Atenção!',
                                    text: "Em breve o curso será liberado em sua conta",
                                    icon: 'warning',
                                    showCancelButton: false,
                                    confirmButtonColor: '#3085d6',
                                    confirmButtonText: 'OK',
                                    allowOutsideClick: false,
                                    allowEscapeKey: false,
                                    allowEnterKey: false
                                }).then((result) => {

                                    window.location.replace(URL_EAD + "course/view.php?id=" + curso_cei);

                                });

                            });

                        }

                    },
                    done: function () {
                        btnForm.html(btnTextOld);
                        btnForm.prop('disabled', false);
                    },
                    error: function (jqXHR, JQueryXHR, txtStatus, errorThrown) {
                        console.log(jqXHR + ' ' + JQueryXHR + ' ' + txtStatus + ' ' + errorThrown);
                        Swal.fire(
                            'Oops! ;c',
                            "Ocorreu algum problema, tente novamente mais tarde!",
                            'error'
                        )
                        btnForm.html(btnTextOld);
                        btnForm.prop('disabled', false);
                    }
                });

            }, function (error) {

                // $('div#errorCartao').html(error);
                Swal.fire(
                    'Oops! ;c',
                    error,
                    'error'
                )
                return false;

            });

        } else {

            //$('div#errorCartao').html(erro);

            Swal.fire(
                'Oops! ;c',
                erro,
                'danger'
            );

            return false;

        }
    }
});

var bol_validate = $('form#formboleto').submit(function (e) {
    e.preventDefault();
}).validate({
    onsubmit: function (element) {
        checkCForm("form#formboleto")
    },
    onfocusout: false,
    errorClass: "is-invalid",
    rules: {
        useBolCpf: {
            required: !0,
            minlength: 14,
            maxlength: 14,
            cpf: !0
        }
    },
    messages: {
        useBolCpf: {
            required: "Digite o cpf do pagador do boleto",
            minlength: "Digite o cpf do pagador do boleto",
            maxlength: "Digite o cpf do pagador do boleto",
            cpf: "CPF inválido"
        }
    },
    errorPlacement: function (error, element) {
        error.appendTo(element.siblings("div.invalid-feedback"))
    },
    submitHandler: function () {
        var btnForm = $("form#formboleto").find('button');
        var btnTextOld = btnForm.html();

        var formData = new FormData();

        formData.append(CSRFTOKEN, CSRFHASH);
        formData.append('curso', curso);
        formData.append('cpf', $('#useBolCpf').val());

        $.ajax({
            url: "checkout/boleto",
            type: 'POST',
            data: formData,
            dataType: 'JSON',
            processData: false,
            contentType: false,
            beforeSend: function () {
                console.log('beforeSend');
                btnForm.prop('disabled', 1);
                btnForm.html('<i class="fas fa-sync fa-spin"></i>');
            },
            success: function (response) {

                if (response.status_code != 200 && response.status_code !== 204) {
                    Swal.fire(
                        response.status_code,
                        response.reason_phrase,
                        'error'
                    )
                } else {

                    Swal.fire({
                        title: 'Boleto Gerado com succeso!',
                        text: "Te enviaremos uma cópia por email",
                        icon: 'success',
                        showCancelButton: true,
                        confirmButtonColor: '#3085d6',
                        confirmButtonText: 'OK',
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        allowEnterKey: false
                    }).then((result) => {

                        Swal.fire({
                            title: 'Atenção!',
                            text: "O curso só será liberado após a confirmação do pagamento. Não se preocupe, nós iremos te avisar quando acontecer ;D",
                            icon: 'warning',
                            showCancelButton: false,
                            confirmButtonColor: '#3085d6',
                            confirmButtonText: 'OK',
                            allowOutsideClick: false,
                            allowEscapeKey: false,
                            allowEnterKey: false
                        });

                        $('div#dados_boleto').show();

                        $('div#bol_hide').remove();
                        $('div#cartao_method').remove();

                        $('#url_boleto').prop('href', response.result._embedded.charges[0].link);

                        $('#payNumber').html(response.result._embedded.charges[0].payNumber);

                    });

                }
            },
            done: function () {
                btnForm.html(btnTextOld);
                btnForm.prop('disabled', false);
            },
            error: function (jqXHR, JQueryXHR, txtStatus, errorThrown) {
                //$('div#errorCartao').html(jqXHR + ' ' + JQueryXHR + ' ' + txtStatus + ' ' + errorThrown);
                Swal.fire(
                    'Oops! ;c',
                    "Ocorreu algum problema, tente novamente mais tarde!",
                    'error'
                )
                btnForm.html(btnTextOld);
                btnForm.prop('disabled', false);
            }
        });
    }
});

$('button#btn-payment').on('click', (e) => {

    let btn = $(e.currentTarget),
        method = btn.data('type');

    $('button#btn-payment.active').removeClass('active');

    btn.addClass('active');

    if (method != 'cartao_method') {
        $('div#cartao_method').hide();
        $('div#' + method).show();
        $('form#formpagamento')[0].reset();
        car_validate.resetForm();
    } else {
        $('div#boleto_method').hide();
        $('div#' + method).show();
        $('form#formboleto')[0].reset();
        bol_validate.resetForm();
    }

});