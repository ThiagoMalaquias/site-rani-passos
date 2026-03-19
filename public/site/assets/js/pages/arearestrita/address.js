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
function validateAddressForm() {
    checkCForm("form#changeInfoForm")
}
$("form#changeInfoForm").validate({
    onsubmit: function (element) {
        validateAddressForm()
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
            required: "Digite o cpf",
            minlength: "Cpf inválido",
            maxlength: "Cpf inválido",
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
        }
    },
    errorPlacement: function (error, element) {
        error.appendTo(element.siblings("div.invalid-feedback"))
    }
});