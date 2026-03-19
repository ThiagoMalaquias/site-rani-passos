function redirectWhats(whatsapp, prodtitulo) {
    $("#send-btn").on("click", () => {
        let msg = $("#nome").val(),
            email = $("#email").val();
        msg = msg.replace(/ /g, "%20"), email = email.replace(/ /g, "%20"), prodtitulo = prodtitulo.replace(/ /g, "%20"), whatsapp = whatsapp.replace(/ /g, "").replace(")", "").replace("(", "").replace("-", ""), window.open(`https://wa.me/55?text=Olá,%20meu%20nome%20é%20**,%20sou%20da%20cidade%20de%20**%20tudo%20bem?%20eu%20gostaria%20de%20um%20orçamento%20do%20produto%20**%20`, "_blank")
    })
}
$(".expand-btn-trigger").click((function (e) {
    e.preventDefault(), $(this).parents(".expand-btn").addClass("triggered"), $("div.products-info").addClass("triggered")
})), $(".back-photo").hover((function () {
    $(this).siblings(".front-photo").toggleClass("hover")
}));