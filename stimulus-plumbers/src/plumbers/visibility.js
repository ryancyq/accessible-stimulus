import Plumber from './plumber';

const defaultOptions = {
  visibility: 'visibility',
  onShown: 'shown',
  onHidden: 'hidden',
};

export const visibilityConfig = { hiddenClass: 'hidden' };

/**
 * Toggles element visibility using class or hidden attribute.
 * @param {HTMLElement} target - Element to toggle
 * @param {boolean} visible - True to show, false to hide
 * @param {string|null} [hiddenClass] - CSS class for hiding (defaults to config)
 */
export function toggleVisibility(target, visible, hiddenClass = '') {
  if (!(target instanceof HTMLElement)) return;

  hiddenClass = hiddenClass ? hiddenClass : visibilityConfig.hiddenClass;
  if (hiddenClass) {
    if (visible) target.classList.remove(hiddenClass);
    else target.classList.add(hiddenClass);
  } else {
    if (visible) target.removeAttribute('hidden');
    else target.setAttribute('hidden', true);
  }
}

export class Visibility extends Plumber {
  /**
   * Creates a new Visibility plumber instance.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} [options] - Configuration options
   * @param {string} [options.visibility='visibility'] - Namespace for visibility helpers
   * @param {string} [options.onShown='shown'] - Method name on plumber instance called after showing
   * @param {string} [options.onHidden='hidden'] - Method name on plumber instance called after hiding
   */
  constructor(controller, options = {}) {
    const { visibility, onShown, onHidden } = Object.assign({}, defaultOptions, options);

    const namespace = typeof visibility === 'string' ? visibility : defaultOptions.namespace;
    const resolver = typeof options.visible === 'string' ? options.visible : 'isVisible';
    if (typeof options.visible !== 'boolean' || options.visible) {
      options.visible = `${namespace}.${resolver}`;
    }
    super(controller, options);

    this.visibility = namespace;
    this.visibilityResolver = resolver;
    this.onShown = onShown;
    this.onHidden = onHidden;

    this.enhance();
  }

  /**
   * Checks if a target element is visible.
   * @param {HTMLElement} target - Element to check
   * @returns {boolean} True if element is visible
   */
  isVisible(target) {
    if (!(target instanceof HTMLElement)) return false;

    const hiddenClass = visibilityConfig.hiddenClass;
    return hiddenClass ? !target.classList.contains(hiddenClass) : !target.hasAttribute('hidden');
  }

  /**
   * Shows the element and dispatches show events.
   * @returns {Promise<void>}
   */
  async show() {
    if (!(this.element instanceof HTMLElement) || this.isVisible(this.element)) return;

    this.dispatch('show');
    toggleVisibility(this.element, true);

    await this.awaitCallback(this.onShown, { target: this.element });
    this.dispatch('shown');
  }

  /**
   * Hides the element and dispatches hide events.
   * @returns {Promise<void>}
   */
  async hide() {
    if (!(this.element instanceof HTMLElement) || !this.isVisible(this.element)) return;

    this.dispatch('hide');
    toggleVisibility(this.element, false);

    await this.awaitCallback(this.onHidden, { target: this.element });
    this.dispatch('hidden');
  }

  enhance() {
    const context = this;
    const helpers = {
      show: context.show.bind(context),
      hide: context.hide.bind(context),
    };
    Object.defineProperty(helpers, 'visible', {
      get() {
        return context.isVisible(context.element);
      },
    });
    Object.defineProperty(helpers, this.visibilityResolver, {
      value: context.isVisible.bind(context),
    });
    Object.defineProperty(this.controller, this.visibility, {
      get() {
        return helpers;
      },
    });
  }
}

/**
 * Factory function to create and attach a Visibility plumber to a controller.
 * @param {Object} controller - Stimulus controller instance
 * @param {Object} [options] - Configuration options
 * @returns {Visibility} Visibility plumber instance
 */
export const attachVisibility = (controller, options) => new Visibility(controller, options);
