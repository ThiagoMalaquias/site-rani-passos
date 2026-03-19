import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat-messages"
export default class extends Controller {
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    const messagesContainer = this.element.querySelector('.messages-container')
    messagesContainer.scrollTop = messagesContainer.scrollHeight
  }
}
