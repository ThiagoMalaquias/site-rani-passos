function validarSenhaForca() {
    let senha = $('input[name=new_password]').val();
    let confirmSenha = $('input[name=new_password_confirm]').val();
    let mensagemNC = '';
    let forca = 0;
    var caracteresEspeciais = "!£$%^&*_@#~?";

    // Contém caracteres especiais
    for (var i = 0; i < senha.length; i++) {
        if (caracteresEspeciais.indexOf(senha.charAt(i)) > -1) {
            forca += 20;
            break;
        }
    }

    // Contém numeros
    if (/\d/.test(senha))
        forca += 20;

    // Contém letras minúsculas
    if (/[a-z]/.test(senha))
        forca += 20;

    // Contém letras maiúsculas
    if (/[A-Z]/.test(senha))
        forca += 20;

    if (senha.length >= 8)
        forca += 20;

    if (confirmSenha.length > 0) {
        if (confirmSenha != senha) {
            mensagemNC = "As senhas não coincidem";
        }
    }

    mostrarForca(forca, mensagemNC, senha);
}

function mostrarForca(forca, mensagemNC, senha) {

    mensagem = '';
    if (forca <= 0 && senha.length <= 0) {
        $("#erroSenhaForca .progress > div").removeClass();
        $("#erroSenhaForca .progress > div").addClass('progress-bar').css({ width: '0%' });
        $("#erroSenhaForca .progress > div").attr('aria-valuenow', 0);
    } else if ((forca > 0 || senha.length > 0) && forca < 30) {
        //$("#erroSenhaForca").html('<div class="progress"><div class="progress-bar bg-danger" role="progressbar" style="width: 25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100"></div></div>');
        $("#erroSenhaForca .progress > div").removeClass();
        $("#erroSenhaForca .progress > div").addClass('progress-bar bg-danger').css({ width: '25%' });
        $("#erroSenhaForca .progress > div").attr('aria-valuenow', 25);
        mensagem = "Fraca";
        $('#register-btn').attr('disabled', true);
    } else if ((forca >= 30) && (forca < 50)) {
        //$("#erroSenhaForca").html('<div class="progress"><div class="progress-bar bg-warning" role="progressbar" style="width: 50%" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100"></div></div>');
        $("#erroSenhaForca .progress > div").removeClass();
        $("#erroSenhaForca .progress > div").addClass('progress-bar bg-warning').css({ width: '50%' });
        $("#erroSenhaForca .progress > div").attr('aria-valuenow', 50);
        mensagem = "Boa";
    } else if ((forca >= 50) && (forca < 70)) {
        //$("#erroSenhaForca").html('<div class="progress"><div class="progress-bar bg-info" role="progressbar" style="width: 75%" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100"></div></div>');
        $("#erroSenhaForca .progress > div").removeClass();
        $("#erroSenhaForca .progress > div").addClass('progress-bar bg-info').css({ width: '75%' });
        $("#erroSenhaForca .progress > div").attr('aria-valuenow', 75);
        mensagem = "Boa";
    } else if ((forca >= 80) && (forca <= 100)) {
        //$("#erroSenhaForca").html('<div class="progress"><div class="progress-bar bg-success" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div></div>');
        $("#erroSenhaForca .progress > div").removeClass();
        $("#erroSenhaForca .progress > div").addClass('progress-bar bg-success').css({ width: '100%' });
        $("#erroSenhaForca .progress > div").attr('aria-valuenow', 100);
        mensagem = "Forte";
    }

    if (mensagemNC !== '') {
        $('#mensagem-forca-senha').html(mensagemNC);
        $('#register-btn').attr('disabled', true);
    } else {
        $('#mensagem-forca-senha').html(mensagem);
    }

}