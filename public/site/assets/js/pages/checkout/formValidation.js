/* $('#use_datanasc').mask('00-00-0000'); */
$('#use_cpf').mask('000.000.000-00', { reverse: true });
$('#useCardCpf').mask('000.000.000-00', { reverse: true });
$('#useBolCpf').mask('000.000.000-00', { reverse: true });

var SPMaskBehavior = function (val) {
    return 11 === val.replace(/\D/g, "").length ? "(00) 00000-0000" : "(00) 0000-00009"
}, spOptions = {
    onKeyPress: function (val, e, field, options) {
        field.mask(SPMaskBehavior.apply({}, arguments), options)
    }
};

$("#use_telefone").mask(SPMaskBehavior, spOptions);

$('#add_cep').mask('00000-000');

$('#cardNumber').mask('0999 0999 0999 0999');

$('#cardCvv').mask('099');

$('#add_uf').mask('AA');

function checkCForm(id) {
    return $(id).validate().checkForm()
}

function validateForm() {
    checkCForm("form#formRegister") /* && grecaptcha.getResponse() */ ? $("button#btnregistrar").prop("disabled", 0) : $("button#btnregistrar").prop("disabled", 1)
}

function limpa_formulário_cep() {
    // Limpa valores do formulário de cep.
    $("#add_rua").val("");
    $("#add_bairro").val("");
    $("#add_cidade").val("");
    $("#add_uf").val("");
    //$("#ibge").val("");
}

//Quando o campo cep perde o foco.
$("#add_cep").on('blur', function () {

    //Nova variável "cep" somente com dígitos.
    var cep = $(this).val().replace(/\D/g, '');

    //Verifica se campo cep possui valor informado.
    if (cep != "") {

        //Expressão regular para validar o CEP.
        var validacep = /^[0-9]{8}$/;

        //Valida o formato do CEP.
        if (validacep.test(cep)) {

            //Preenche os campos com "..." enquanto consulta webservice.
            $("#add_rua").val("...");
            $("#add_bairro").val("...");
            $("#add_cidade").val("...");
            $("#add_uf").val("...");
            //$("#ibge").val("...");

            //Consulta o webservice viacep.com.br/
            $.getJSON("https://viacep.com.br/ws/" + cep + "/json/?callback=?", function (dados) {

                if (!("erro" in dados)) {
                    //Atualiza os campos com os valores da consulta.
                    $("#add_rua").val(dados.logradouro);
                    $("#add_bairro").val(dados.bairro);
                    $("#add_cidade").val(dados.localidade);
                    $("#add_uf").val(dados.uf);
                    //$("#ibge").val(dados.ibge);
                    validateForm()
                } //end if.
                else {
                    //CEP pesquisado não foi encontrado.
                    limpa_formulário_cep();
                    validateForm()
                }
            });
        } else {
            //cep é inválido.
            limpa_formulário_cep();
            validateForm()
        }
    } else {
        //cep sem valor, limpa formulário.
        limpa_formulário_cep();
        validateForm()
    }
});

$('#cardHolder').mask("#", {
    maxlength: false,
    translation: {
        '#': { pattern: /[A-z À-ÿ]/, recursive: true }
    }
});

$("form#formRegister").validate({
    onkeyup: function (element) {
        $(element).valid(), validateForm()
    },
    errorClass: "is-invalid",
    validClass: "is-valid",
    rules: {
        use_name: {
            required: !0,
            minlength: 3
        },
        use_email: {
            required: !0,
            email: !0
        },
        use_cpf: {
            required: !0,
            minlength: 14,
            maxlength: 14,
            cpf: !0
        },
        use_telefone: {
            required: !0,
            minlength: 14,
            maxlength: 15
        },
        add_cep: {
            required: !0,
        },
        add_rua: {
            required: !0,
        },
        add_numero: {
            required: !0,
        },
        add_bairro: {
            required: !0,
        },
        add_cidade: {
            required: !0,
        },
        add_uf: {
            required: !0,
            minlength: 2,
            maxlength: 2
        },
        use_password: {
            required: !0,
            minlength: 8,
            maxlength: 30
        },
        use_password_confirm: {
            required: !0,
            equalTo: "#use_password"
        }
    },
    messages: {
        use_name: {
            required: "Informe um nome",
            minlength: "Informe um nome"
        },
        use_email: {
            required: "Informe um email",
            email: "Informe um email válido"
        },
        use_cpf: {
            required: "Digite seu cpf",
            minlength: "Digite seu cpf",
            maxlength: "Digite seu cpf",
            cpf: "CPF inválido"
        },
        use_telefone: {
            required: "Informe um telefone",
            minlength: "Informe um telefone",
            maxlength: "Informe um telefone"
        },
        add_cep: {
            required: "Digite seu cep"
        },
        add_rua: {
            required: "Digite sua rua"
        },
        add_numero: {
            required: "Digite o numero da residência"
        },
        add_bairro: {
            required: "Digite seu bairro"
        },
        add_cidade: {
            required: "Digite sua cidade"
        },
        add_uf: {
            required: "Digite seu estado",
            minlength: "Digite seu estado",
            maxlength: "Digite seu estado"
        },
        use_password: {
            required: "Informe uma senha",
            minlength: "Sua nova senha deve ter no minimo 8 caracteres",
            maxlength: "Sua nova senha pode ter no máximo 30 caracteres"
        },
        use_password_confirm: {
            required: "Confirme sua senha",
            equalTo: "As senhas não conferem"
        }
    },
    errorPlacement: function (error, element) {
        error.appendTo(element.siblings("div.invalid-feedback"))
    }
});
