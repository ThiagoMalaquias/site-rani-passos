AOS.init({
    duration: 2e3
}), $(() => {
    let imgs = $("figure.image").find("img"),
        oldsrc = "",
        newsrc = "";
    imgs.each((index, item) => {
        oldsrc = "", newsrc = "", oldsrc = $(item).attr("src"), newsrc = "https://admin.webgopher.com.br" + oldsrc, $(item).attr("src", newsrc)
    })
});