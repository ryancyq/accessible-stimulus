import { Controller } from '@hotwired/stimulus';
import { attachDismisser } from '../plumbers/dismisser.js';

export default class extends Controller {
  static targets = ['trigger'];

  connect() {
    attachDismisser(this, { trigger: this.hasTriggerTarget ? this.triggerTarget : null });
  }
}
