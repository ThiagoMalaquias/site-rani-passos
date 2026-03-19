import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
  }

  openNotification() {
    const dropdownMenu = document.querySelector('ul.dropdown-menu');
    const dropdownItem = document.querySelector('a.dropdown-item h6');

    if (dropdownMenu.classList.contains('d-none')) {
      dropdownMenu.classList.remove('d-none');
      dropdownItem.classList.remove('text-white');
      dropdownMenu.classList.add('show');
    } else {
      dropdownMenu.classList.remove('show');
      dropdownMenu.classList.add('d-none');
    }
  }

  async hideAdvertisement() {
    const res = await fetch(`/user_site_advertisements`, {
      method: 'POST',
      headers: {
        'Content-type': 'application/json; charset=UTF-8',
      }
    })

    JSON.parse(await res.text());

    $('#anuncio').modal('hide')
  }
}
