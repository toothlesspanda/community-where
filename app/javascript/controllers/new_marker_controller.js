import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {
    static targets = [
        "parentSelect",
        "childSelect",
        "childSelectWrapper",
        "newChildWrapper",
        "newParentWrapper",
        "modal"
    ]

    connect() {
        this.categories = JSON.parse(this.parentSelectTarget.dataset.categories)
    }

    submitEnd(event) {
        if (event.detail.success) {
            const modal = bootstrap.Modal.getInstance(
                this.element.closest(".modal")
            )

            modal.hide()
        }
    }

    handleParentChange(event) {
        const value = event.target.value

        if (value === "other") {
            this.newParentWrapperTarget.classList.remove("d-none")
            this.newChildWrapperTarget.classList.remove("d-none")
            this.childSelectWrapperTarget.classList.add("d-none")
            return
        } else {
            // mostrar select por default
            this.newChildWrapperTarget.classList.add("d-none")
            this.newParentWrapperTarget.classList.add("d-none")
            this.childSelectWrapperTarget.classList.remove("d-none")
        }

        const parentId = parseInt(value)
        const parent = this.categories.find(cat => cat.id === parentId)

        this.childSelectTarget.innerHTML =
            '<option value="">Selecionar subcategoria</option>'

        if (!parent) return

        parent.children.forEach(child => {
            const option = document.createElement("option")
            option.value = child.id
            option.textContent = child.code
            this.childSelectTarget.appendChild(option)
        })


        const otherOption = document.createElement("option")
        otherOption.value = "other"
        otherOption.textContent = "Outra…"
        this.childSelectTarget.appendChild(otherOption)
    }

    handleChildChange(event) {
        if (event.target.value === "other") {
            this.childSelectWrapperTarget.classList.add("d-none")
            this.newChildWrapperTarget.classList.remove("d-none")
        }
    }

}