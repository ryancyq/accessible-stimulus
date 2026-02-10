import Plumber from './plumber';

const defaultOptions = {
  trigger: null,
  events: ['click'],
  onDismissed: 'dismissed',
};

export class Dismisser extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);

    const { trigger, events, onDismissed } = Object.assign({}, defaultOptions, options);
    this.onDismissed = onDismissed;
    this.trigger = trigger || this.element;
    this.events = events;

    this.enhance();
    this.observe();
  }

  dismiss = async (event) => {
    const { target } = event;
    if (!(target instanceof HTMLElement)) return;
    if (this.element.contains(target)) return;
    if (!this.visible) return;

    this.dispatch('dismiss');
    await this.awaitCallback('onDismissed', { target: this.trigger });
    this.dispatch('dismissed');
  };

  observe() {
    this.events.forEach((event) => {
      window.addEventListener(event, this.dismiss, true);
    });
  }

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

export const attachDismisser = (controller, options) => new Dismisser(controller, options);
