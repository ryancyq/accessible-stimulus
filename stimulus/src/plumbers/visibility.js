import Plumber from './plumber';

const defaultOptions = {
  visibility: 'visibility',
  onShown: 'shown',
  onHidden: 'hidden',
};

export const visibilityConfig = { hiddenClass: 'hidden' };

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

  isVisible(target) {
    if (!(target instanceof HTMLElement)) return false;

    const hiddenClass = visibilityConfig.hiddenClass;
    return hiddenClass ? !target.classList.contains(hiddenClass) : !target.hasAttribute('hidden');
  }

  async show() {
    if (!(this.element instanceof HTMLElement) || this.isVisible(this.element)) return;

    this.dispatch('show');
    toggleVisibility(this.element, true);

    await this.awaitCallback('onShown', { target: this.element });
    this.dispatch('shown');
  }

  async hide() {
    if (!(this.element instanceof HTMLElement) || !this.isVisible(this.element)) return;

    this.dispatch('hide');
    toggleVisibility(this.element, false);

    await this.awaitCallback('onHidden', { target: this.element });
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

export const attachVisibility = (controller, options) => new Visibility(controller, options);
