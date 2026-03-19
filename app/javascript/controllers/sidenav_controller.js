import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidenav"
export default class extends Controller {
  connect() {
    console.log("SidenavController connected");

    this.sidenav = document.getElementById('sidenav-main');
    this.body = document.getElementsByTagName('body')[0];
    this.html = document.getElementsByTagName('html')[0];

    this.className = 'g-sidenav-pinned';
    this.setupEventListeners();
  }

  setupEventListeners() {
    // Adiciona listener para fechar sidenav ao clicar fora
    this.html.addEventListener("click", (e) => {
      if (this.body.classList.contains('g-sidenav-pinned') &&
        !e.target.classList.contains('sidenav-toggler-line')) {
        this.body.classList.remove(this.className);
      }
    });
  }

  toggle() {
    if (this.body.classList.contains(this.className)) {
      this.body.classList.remove(this.className);
      setTimeout(() => {
        this.sidenav.classList.remove('bg-white');
      }, 100);
      this.sidenav.classList.remove('bg-transparent');
    } else {
      this.body.classList.add(this.className);
      this.sidenav.classList.add('bg-white');
      this.sidenav.classList.remove('bg-transparent');
    }
  }
}