import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="report-user-tag"
export default class extends Controller {
  connect() {
    $('#phone').mask('(00) 00000-0000');
    $('.js-example-basic-multiple').select2();
  }
}
