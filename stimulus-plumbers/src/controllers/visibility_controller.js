import { Controller } from '@hotwired/stimulus';
import { attachDismisser, attachVisibility, attachShifter } from '../plumbers';

export default class extends Controller {
  static targets = ['content'];

  connect() {
    attachDismisser(this);
  }

  contentTargetConnected(target) {
    attachShifter(this, { element: target });
    attachVisibility(this, { element: target });
  }

  async dismissed() {
    if (!this.hasContentTarget) return;

    await this.visibility.hide();
  }

  async toggle() {
    if (!this.hasContentTarget) return;

    if (this.visibility.visible) {
      await this.visibility.hide();
    } else {
      await this.visibility.show();
      this.shift(this.contentTarget);
    }
  }
}
