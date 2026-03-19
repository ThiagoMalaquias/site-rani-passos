var win = navigator.platform.indexOf('Win') > -1;
if (win && document.querySelector('#sidenav-scrollbar')) {
  var options = {
    damping: '0.5'
  }
  Scrollbar.init(document.querySelector('#sidenav-scrollbar'), options);
}



var modal = ""
$("[role='myBtnModal']").click((event) => {
  const ariaLabelledBy = $(event.currentTarget).attr("aria-labelledby");
  modal = $(`#${ariaLabelledBy}`)
  modal.show()
})

$(".close").click((event) => {
  modal.hide();
})

$(window).click((event) => {
  if ($(event.target).is(modal)) {
    modal.hide();
  }
})