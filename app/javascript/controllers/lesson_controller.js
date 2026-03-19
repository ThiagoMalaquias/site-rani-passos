import { Controller } from "@hotwired/stimulus"

// data-controller="lesson"
export default class extends Controller {
  static targets = [
    "groupsWrapper",
    "group",
    "template",
    "wombSelect",
    "componentSelect",
    "lectureSelect",
    "videosWrapper"
  ]

  static values = {
    prefix: String,
    fetchComponentsUrl: String,
    fetchLecturesUrl: String,
    fetchVideosUrl: String
  }

  connect() {
    this.groupTargets.forEach(group => this.initializeGroup(group))
  }

  addGroup() {
    if (!this.hasTemplateTarget) return
    const fragment = this.templateTarget.content.cloneNode(true)
    const group = fragment.querySelector("[data-lesson-target='group']")
    this.initializeGroup(group)
    this.groupsWrapperTarget.appendChild(fragment)
  }

  initializeGroup(group) {
    if (!group) return

    const templatePrefix = group.dataset.templatePrefix
    const existingId = group.dataset.groupIndex
    const groupId = existingId && existingId !== "" ? existingId : Date.now().toString()

    group.dataset.groupIndex = groupId

    const finalPrefix = templatePrefix
      .replace("TEMPLATE_KEY", groupId)

    console.log(finalPrefix)

    group.querySelectorAll("select, input").forEach(element => {
      if (element.name) element.name = element.name.replace(templatePrefix, finalPrefix)
      if (!existingId && element.id) element.id = `${element.id}_${groupId}`
    })

    if (!existingId) {
      group.querySelectorAll("label[for]").forEach(label => {
        label.htmlFor = `${label.htmlFor}_${groupId}`
      })
    }

    // Guarda o prefixo já ajustado; nas próximas execuções não duplica
    group.dataset.templatePrefix = finalPrefix
  }

  configureGroup(fragment) {
    const groupId = Date.now().toString()
    const group = fragment.querySelector("[data-lesson-target='group']")
    group.dataset.groupIndex = groupId

    const templatePrefix = group.dataset.templatePrefix // ex: "lesson[lesson_womb_component_lectures_attributes][TEMPLATE_KEY]"
    const finalPrefix = templatePrefix.replace("TEMPLATE_KEY", groupId)

    group.querySelectorAll("select, input").forEach(element => {
      if (element.name) {
        element.name = element.name.replace(templatePrefix, finalPrefix)
      }
      if (element.id) {
        element.id = `${element.id}_${groupId}`
      }
    })

    group.querySelectorAll("label[for]").forEach(label => {
      label.htmlFor = `${label.htmlFor}_${groupId}`
    })
  }

  adjustNames(fragment) {
    const groupId = Date.now().toString()
    const group = fragment.querySelector("[data-group-index]")
    if (group) group.dataset.groupIndex = groupId

    fragment.querySelectorAll("select, input").forEach(element => {
      if (element.name) {
        element.name = element.name.replace(/\[\]([^\[]*)$/, `[${groupId}]$1`)
        element.name = element.name.replace("lesson[", `${this.prefixValue}[`)
      }
      if (element.id) {
        element.id = `${element.id}_${groupId}`
      }
    })

    fragment.querySelectorAll("label[for]").forEach(label => {
      label.setAttribute("for", `${label.getAttribute("for")}_${groupId}`)
    })
  }

  removeGroup(event) {
    event.preventDefault()
    const group = event.target.closest("[data-lesson-target='group']")
    if (group) group.remove()
  }

  async loadComponents(event) {
    const group = event.target.closest("[data-lesson-target='group']")
    const wombId = event.target.value

    if (!group) return
    if (!wombId) {
      this.populateSelect(group.querySelector("[data-lesson-target='componentSelect']"), [], { defaultOption: "Selecione uma matriz" })
      this.populateSelect(group.querySelector("[data-lesson-target='lectureSelect']"), [], { defaultOption: "Selecione um módulo" })
      this.renderVideos(group, [])
      return
    }

    try {
      const url = this.fetchComponentsUrlValue.replace(":womb_id", wombId)
      const data = await this.fetchJSON(url)
      this.populateSelect(group.querySelector("[data-lesson-target='componentSelect']"), data, { defaultOption: "Selecione um módulo" })
      this.populateSelect(group.querySelector("[data-lesson-target='lectureSelect']"), [], { defaultOption: "Selecione um módulo" })
      this.renderVideos(group, [])
    } catch (error) {
      console.error(error)
    }
  }

  async loadLectures(event) {
    const group = event.target.closest("[data-lesson-target='group']")
    const wombSelect = group?.querySelector("[data-lesson-target='wombSelect']")
    const wombId = wombSelect?.value
    const componentId = event.target.value

    if (!group || !wombId || !componentId) {
      this.populateSelect(group?.querySelector("[data-lesson-target='lectureSelect']"), [], { defaultOption: "Selecione um módulo" })
      this.renderVideos(group, [])
      return
    }

    try {
      const url = this.fetchLecturesUrlValue
        .replace(":womb_id", wombId)
        .replace(":component_id", componentId)

      const data = await this.fetchJSON(url)
      this.populateSelect(group.querySelector("[data-lesson-target='lectureSelect']"), data, { defaultOption: "Selecione uma aula" })
      this.renderVideos(group, [])
    } catch (error) {
      console.error(error)
    }
  }

  async loadVideos(event) {
    const group = event.target.closest("[data-lesson-target='group']")
    const wombId = group?.querySelector("[data-lesson-target='wombSelect']")?.value
    const componentId = group?.querySelector("[data-lesson-target='componentSelect']")?.value
    const lectureId = event.target.value

    if (!group || !wombId || !componentId || !lectureId) {
      this.renderVideos(group, [])
      return
    }

    try {
      const url = this.fetchVideosUrlValue
        .replace(":womb_id", wombId)
        .replace(":component_id", componentId)
        .replace(":lecture_id", lectureId)

      const data = await this.fetchJSON(url)
      this.renderVideos(group, data)
    } catch (error) {
      console.error(error)
    }
  }

  async fetchJSON(url) {
    const response = await fetch(url, { headers: { Accept: "application/json" } })
    if (!response.ok) throw new Error(`Falha ao buscar ${url}`)
    return await response.json()
  }

  populateSelect(select, options, { defaultOption = "" } = {}) {
    if (!select) return
    select.innerHTML = ""

    const placeholder = document.createElement("option")
    placeholder.value = ""
    placeholder.textContent = defaultOption
    select.appendChild(placeholder)

    options.forEach(option => {
      const opt = document.createElement("option")
      opt.value = option.id
      opt.textContent = option.title
      select.appendChild(opt)
    })
  }

  renderVideos(group, videos) {
    if (!group) return
    const wrapper = group.querySelector("[data-lesson-target='videosWrapper']")
    if (!wrapper) return

    const groupId = group.dataset.groupIndex
    const templatePrefix = group.dataset.templatePrefix
    const finalPrefix = templatePrefix
      .replace("lesson[", `${this.prefixValue}[`)
      .replace("TEMPLATE_KEY", groupId)

    if (!videos.length) {
      wrapper.innerHTML = "<strong class='ms-2'>Selecione uma aula</strong>"
      return
    }

    const container = document.createElement("div")
    container.className = "row"

    videos.forEach(video => {
      const col = document.createElement("div")
      col.className = "col-md-12"

      const videoId = String(video.id).replace(/"/g, "");

      const input = document.createElement("input")
      input.type = "checkbox"
      input.className = "form-check-input"
      input.value = videoId
      input.id = `lecture_video_${video.id}_${groupId}`

      if (this.prefixValue.includes("review")) {
        input.name = `lesson[lesson_review_womb_component_lectures_attributes][${groupId}][videos][]`
      } else {
        input.name = `lesson[lesson_lecture_videos_attributes][][lecture_video_id]`
      }

      const label = document.createElement("label")
      label.className = "form-check-label"
      label.htmlFor = input.id
      label.textContent = video.title

      col.appendChild(input)
      col.appendChild(label)
      container.appendChild(col)
    })

    wrapper.innerHTML = ""
    wrapper.appendChild(container)
  }
}