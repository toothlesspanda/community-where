// app/javascript/controllers/attend_modal_controller.js
import { Controller } from '@hotwired/stimulus';
import { Modal } from 'bootstrap';

export default class extends Controller {
    static values = {
        frameId: String,
    };

    connect() {
        this.modal = new Modal(this.element);
        this.frame = this.hasFrameIdValue ? document.getElementById(this.frameIdValue) : null;

        document.addEventListener('turbo:before-stream-render', this.toggleModalOnStreamRender.bind(this));
        this.element.addEventListener('hidden.bs.modal', this.resetContent.bind(this));
    }

    disconnect() {
        document.removeEventListener('turbo:before-stream-render', this.toggleModalOnStreamRender.bind(this));
        this.element.removeEventListener('hidden.bs.modal', this.resetContent.bind(this));
    }

    toggleModalOnStreamRender = (event) => {
        const renderedFrame = event.detail.newStream.target;
        if (renderedFrame !== this.frameIdValue) return;
        const isCloseAction = event.detail.newStream.templateContent.querySelector('[data-close]')?.dataset?.close;

        if (isCloseAction) this.modal.hide();
        else this.modal.show();
    };

    resetContent() {
        if (this.frame) this.frame.innerHTML = '';
    }
}