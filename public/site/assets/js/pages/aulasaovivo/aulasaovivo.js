var src = '';
var aul_name = '';
var modal = '';

function download(uri, nome) {
    var link = document.createElement("a");
    link.download = nome;
    link.href = uri;

    link.addEventListener('click', function () {
        $.modal.close();
        $('#mensagemnewsletter').hide();
        $('input#name').val('');
        $('input#email').val('');
        $('form#newsletterForm').show();
    });

    link.click();

}

function checkCForm(id) {
    return $(id).validate().checkForm()
}

function validateForm() {
    checkCForm("form#newsletterForm")
}

validator = $("form#newsletterForm").validate({
    onkeyup: function (element) {
        $(element).valid(), validateForm()
    },
    errorClass: "is-invalid",
    validClass: "is-valid",
    rules: {
        email: {
            required: !0,
            email: !0
        },
        name: {
            required: !0
        }
    },
    messages: {
        email: {
            required: "Informe um email",
            email: "Informe um email válido"
        },
        name: {
            required: "Digite seu nome"
        }
    },
    errorPlacement: function (error, element) {
        error.appendTo(element.siblings("div.invalid-feedback"))
    },
    submitHandler: function (form) {
        var formData = new FormData(form)
        $.ajax({
            url: `/leads.json?live_lesson_id=${aul_name}`,
            type: 'POST',
            data: formData,
            dataType: 'JSON',
            processData: false,
            contentType: false,
            beforeSend: function () {
                $('form#newsletterForm').find("button[type=submit]").prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i>');
            },
            success: function (response) {
                if(response.error){
                    alert(response.error)
                    return
                }

                src = response.live_lesson.material
                aul_name = response.live_lesson.title
                email = $('input#email').val();
                $('form#newsletterForm').hide();
                $('#mensagemnewsletter').show();
                $('#mensagemnewsletter span').prepend(`
                <a href="${src}" class="btn-solid matdown" id="baixar" target="_blank" download>
                    Baixar
                </a>`);

                download(src, aul_name);
            },
            complete: function () {
                $('form#newsletterForm').find("button[type=submit]").prop('disabled', false).html('FAZER DONWLOAD');
                validator.resetForm();
            },
            error: function (jqXHR, JQueryXHR, txtStatus, errorThrown) {
                $('form#newsletterForm').find("button[type=submit]").prop('disabled', false).html('FAZER DONWLOAD');
                console.log(jqXHR + ' ' + JQueryXHR + ' ' + txtStatus + ' ' + errorThrown);
            }
        });
    }
});

$('a#materialbtn').on('click', function (e) {
    e.preventDefault();
    console.log(e.currentTarget)
    src = $(e.currentTarget).attr('href');
    aul_name = $(e.currentTarget).data('name');
    console.log(aul_name)
    $("#modalnews").modal();
    modal = $("#modalnews").html();
    validator.resetForm();
});