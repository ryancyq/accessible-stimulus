import Plumber from './plumber';

const defaultOptions = {
  trigger: null,
  events: ['click'],
  onDismissed: 'dismissed',
};

export class Dismisser extends Plumber {
  /**
   * Creates a new Dismisser plumber instance for handling outside-click dismissals.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} [options] - Configuration options
   * @param {HTMLElement} [options.trigger] - Trigger element (defaults to controller element)
   * @param {string[]} [options.events=['click']] - Events to listen for dismissal
   * @param {string} [options.onDismissed='dismissed'] - Callback name when dismissed
   */
  constructor(controller, options = {}) {
    super(controller, options);

    const { trigger, events, onDismissed } = Object.assign({}, defaultOptions, options);
    this.onDismissed = onDismissed;
    this.trigger = trigger || this.element;
    this.events = events;

    this.enhance();
    this.observe();
  }

  /**
   * Handles dismissal when clicking outside the element.
   * @param {Event} event - DOM event
   * @returns {Promise<void>}
   */
  dismiss = async (event) => {
    const { target } = event;
    if (!(target instanceof HTMLElement)) return;
    if (this.element.contains(target)) return;
    if (!this.visible) return;

    this.dispatch('dismiss');
    await this.awaitCallback('onDismissed', { target: this.trigger });
    this.dispatch('dismissed');
  };

  /**
   * Starts observing configured events for dismissal.
   */
  observe() {
    this.events.forEach((event) => {
      window.addEventListener(event, this.dismiss, true);
    });
  }

  /**
   * Stops observing events for dismissal.
   */
  unobserve() {
    this.events.forEach((event) => {
      window.removeEventListener(event, this.dismiss, true);
    });
  }

  enhance() {
    const context = this;
    const superDisconnect = context.controller.disconnect.bind(context.controller);
    Object.assign(this.controller, {
      disconnect: () => {
        context.unobserve();
        superDisconnect();
      },
    });
  }
}

/**
 * Factory function to create and attach a Dismisser plumber to a controller.
 * @param {Object} controller - Stimulus controller instance
 * @param {Object} [options] - Configuration options
 * @returns {Dismisser} Dismisser plumber instance
 */
export const attachDismisser = (controller, options) => new Dismisser(controller, options);
