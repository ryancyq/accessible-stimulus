import { isWithinViewport } from './support';

const defaultOptions = {
  element: null,
  visible: true,
  dispatch: true,
  prefix: '',
};

export default class Plumber {
  constructor(controller, options = {}) {
    this.controller = controller;

    const config = Object.assign({}, defaultOptions, options);
    const { element, visible, dispatch, prefix } = config;
    this.element = element || controller.element;
    this.visibleOnly = !!visible;
    this.visibleCallback = typeof visible === 'string' ? visible : null;
    this.notify = !!dispatch;
    this.prefix = typeof prefix === 'string' && prefix ? prefix : controller.identifier;
  }

  get visible() {
    if (!(this.element instanceof HTMLElement)) return false;
    if (!this.visibleOnly) return true;

    return isWithinViewport(this.element) && this.isVisible(this.element);
  }

  isVisible(target) {
    if (this.visibleCallback) {
      const callback = this.findCallback(this.visibleCallback);
      if (typeof callback == 'function') return callback(target);
    }

    if (!(target instanceof HTMLElement)) return false;
    return !target.hasAttribute('hidden');
  }

  dispatch(name, { target = null, prefix = null, detail = null } = {}) {
    if (!this.notify) return;

    return this.controller.dispatch(name, {
      target: target || this.element,
      prefix: prefix || this.prefix,
      detail: detail,
    });
  }

  findCallback(name) {
    if (typeof name !== 'string') return;

    const context = this;
    const callback =
      typeof context[name] === 'function'
        ? context[name]
        : context[name].split('.').reduce((acc, key) => acc && acc[key], context.controller);
    if (typeof callback === 'function') return callback.bind(context.controller);
  }

  async awaitCallback(callback, ...args) {
    if (typeof callback === 'string') callback = this.findCallback(callback);
    if (typeof callback === 'function') {
      const result = callback(...args);
      if (result instanceof Promise) return await result;
      else return result;
    }
  }
}
