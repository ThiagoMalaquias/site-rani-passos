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
                    validateAddressForm();
                    //$("#ibge").val(dados.ibge);
                } //end if.
                else {
                    //CEP pesquisado não foi encontrado.
                    limpa_formulário_cep();
                    validateAddressForm();
                }
            });
        } else {
            //cep é inválido.
            limpa_formulário_cep();
            validateAddressForm();
        }
    } else {
        //cep sem valor, limpa formulário.
        limpa_formulário_cep();
        validateAddressForm();
    }
});