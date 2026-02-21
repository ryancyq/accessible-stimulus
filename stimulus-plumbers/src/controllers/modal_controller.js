import { Controller } from '@hotwired/stimulus';
import { FocusTrap } from '../focus';
import { announce } from '../aria';
import { attachDismisser } from '../plumbers';

/**
 * Modal Dialog Controller
 * Implements WAI-ARIA Dialog (Modal) pattern
 * Supports both native <dialog> elements and custom implementations
 */
export default class ModalController extends Controller {
  static targets = ['modal', 'overlay'];

  connect() {
    if (!this.hasModalTarget) {
      console.error('ModalController requires a modal target. Add data-modal-target="modal" to your element.');
      return;
    }

    this.isNativeDialog = this.modalTarget instanceof HTMLDialogElement;

    if (this.isNativeDialog) {
      this.modalTarget.addEventListener('cancel', this.close);
      this.modalTarget.addEventListener('click', this.handleBackdropClick);
    } else {
      this.focusTrap = new FocusTrap(this.modalTarget, {
        escapeDeactivates: true,
      });

      attachDismisser(this, { element: this.modalTarget });
    }
  }

  dismissed = () => {
    this.close();
  };

  disconnect() {
    if (this.isNativeDialog) {
      this.modalTarget.removeEventListener('cancel', this.close);
      this.modalTarget.removeEventListener('click', this.handleBackdropClick);
    }
  }

  open(event) {
    if (event) event.preventDefault();
    if (!this.hasModalTarget) return;

    if (this.isNativeDialog) {
      this.previouslyFocused = document.activeElement;
      this.modalTarget.showModal();
    } else {
      const targetToShow = this.hasOverlayTarget ? this.overlayTarget : this.modalTarget;
      targetToShow.hidden = false;

      document.body.style.overflow = 'hidden';

      if (this.focusTrap) {
        this.focusTrap.activate();
      }
    }

    announce('Modal opened');
  }

  close(event) {
    if (event) event.preventDefault();
    if (!this.hasModalTarget) return;

    if (this.isNativeDialog) {
      this.modalTarget.close();

      if (this.previouslyFocused && this.previouslyFocused.isConnected) {
        setTimeout(() => {
          this.previouslyFocused.focus();
        }, 0);
      }
    } else {
      const targetToHide = this.hasOverlayTarget ? this.overlayTarget : this.modalTarget;
      targetToHide.hidden = true;

      document.body.style.overflow = '';

      if (this.focusTrap) {
        this.focusTrap.deactivate();
      }
    }

    announce('Modal closed');
  }

  handleBackdropClick = (event) => {
    const rect = this.modalTarget.getBoundingClientRect();
    const isOutsideDialog =
      event.clientY < rect.top ||
      event.clientY > rect.bottom ||
      event.clientX < rect.left ||
      event.clientX > rect.right;

    if (isOutsideDialog) {
      this.close();
    }
  };
}
