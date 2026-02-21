import { Controller } from '@hotwired/stimulus';
import { attachShifter } from '../plumbers';

export default class extends Controller {
  static targets = ['content'];

  connect() {
    attachShifter(this, { element: this.hasContentTarget ? this.contentTarget : null });
  }
}
