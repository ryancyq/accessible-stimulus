import Plumber from './plumber';
import { defineRect, viewportRect, directionMap } from './plumber/support';

const defaultOptions = {
  anchor: null,
  events: ['click'],
  placement: 'bottom',
  alignment: 'start',
  onFlipped: 'flipped',
};

export class Flipper extends Plumber {
  /**
   * Creates a new Flipper plumber instance for smart positioning relative to an anchor.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} [options] - Configuration options
   * @param {HTMLElement} [options.anchor] - Anchor element for positioning
   * @param {string[]} [options.events=['click']] - Events triggering flip calculation
   * @param {string} [options.placement='bottom'] - Initial placement direction ('top', 'bottom', 'left', 'right')
   * @param {string} [options.alignment='start'] - Alignment ('start', 'center', 'end')
   * @param {string} [options.onFlipped='flipped'] - Callback name when flipped
   */
  constructor(controller, options = {}) {
    super(controller, options);

    const { anchor, events, placement, alignment, onFlipped } = Object.assign({}, defaultOptions, options);
    this.anchor = anchor;
    this.events = events;
    this.placement = placement;
    this.alignment = alignment;
    this.onFlipped = onFlipped;

    this.enhance();
    this.observe();
  }

  /**
   * Attempts to place element in configured direction, flipping to opposite direction if needed.
   * For example, if placement is 'bottom' but no space below anchor, flips to 'top'.
   * @returns {Promise<void>}
   */
  flip = async () => {
    if (!this.visible) return;

    this.dispatch('flip');
    const positionStyle = window.getComputedStyle(this.element);
    if (positionStyle['position'] != 'absolute') this.element.style['position'] = 'absolute';

    const placement = this.flippedRect(this.anchor.getBoundingClientRect(), this.element.getBoundingClientRect());
    for (const [key, value] of Object.entries(placement)) {
      this.element.style[key] = value;
    }

    await this.awaitCallback('onFlipped', { target: this.element, placement });
    this.dispatch('flipped', { detail: { placement } });
  };

  /**
   * Determines the best position that fits within viewport boundaries.
   * @param {DOMRect} anchorRect - Anchor element's bounding rect
   * @param {DOMRect} referenceRect - Reference element's bounding rect
   * @returns {Object} Position object with top and left styles
   */
  flippedRect(anchorRect, referenceRect) {
    const candidateRects = this.quadrumRect(anchorRect, viewportRect());
    const candidates = [this.placement, directionMap[this.placement]];
    let flipped = {};
    while (!Object.keys(flipped).length && candidates.length > 0) {
      const candidate = candidates.shift();
      if (!this.biggerRectThan(candidateRects[candidate], referenceRect)) continue;

      const placementRect = this.quadrumPlacement(anchorRect, candidate, referenceRect);
      const alignmentRect = this.quadrumAlignment(anchorRect, candidate, placementRect);
      flipped['top'] = `${alignmentRect['top'] + window.scrollY}px`;
      flipped['left'] = `${alignmentRect['left'] + window.scrollX}px`;
    }
    if (!Object.keys(flipped).length) {
      flipped['top'] = '';
      flipped['left'] = '';
    }
    return flipped;
  }

  /**
   * Calculates available space in each direction around the inner rect within outer rect.
   * @param {Object} inner - Inner rect object
   * @param {Object} outer - Outer rect object
   * @returns {Object} Rect objects for each direction (left, right, top, bottom)
   */
  quadrumRect(inner, outer) {
    return {
      left: defineRect({
        x: outer.x,
        y: outer.y,
        width: inner.x - outer.x,
        height: outer.height,
      }),
      right: defineRect({
        x: inner.x + inner.width,
        y: outer.y,
        width: outer.width - (inner.x + inner.width),
        height: outer.height,
      }),
      top: defineRect({
        x: outer.x,
        y: outer.y,
        width: outer.width,
        height: inner.y - outer.y,
      }),
      bottom: defineRect({
        x: outer.x,
        y: inner.y + inner.height,
        width: outer.width,
        height: outer.height - (inner.y + inner.height),
      }),
    };
  }

  /**
   * Calculates placement rect for reference element in given direction from anchor.
   * @param {Object} anchor - Anchor rect object
   * @param {string} direction - Direction ('top', 'bottom', 'left', 'right')
   * @param {Object} reference - Reference rect object
   * @returns {Object} Placed rect object
   * @throws {string} If direction is invalid
   */
  quadrumPlacement(anchor, direction, reference) {
    switch (direction) {
      case 'top':
        return defineRect({
          x: reference.x,
          y: anchor.y - reference.height,
          width: reference.width,
          height: reference.height,
        });
      case 'bottom':
        return defineRect({
          x: reference.x,
          y: anchor.y + anchor.height,
          width: reference.width,
          height: reference.height,
        });
      case 'left':
        return defineRect({
          x: anchor.x - reference.width,
          y: reference.y,
          width: reference.width,
          height: reference.height,
        });
      case 'right':
        return defineRect({
          x: anchor.x + anchor.width,
          y: reference.y,
          width: reference.width,
          height: reference.height,
        });
      default:
        throw `Unable place at the quadrum, ${direction}`;
    }
  }

  /**
   * Applies alignment adjustment to placed rect based on configuration.
   * @param {Object} anchor - Anchor rect object
   * @param {string} direction - Direction ('top', 'bottom', 'left', 'right')
   * @param {Object} reference - Reference rect object
   * @returns {Object} Aligned rect object
   * @throws {string} If direction is invalid
   */
  quadrumAlignment(anchor, direction, reference) {
    switch (direction) {
      case 'top':
      case 'bottom': {
        let alignment = anchor.x;
        if (this.alignment === 'center') alignment = anchor.x + anchor.width / 2 - reference.width / 2;
        else if (this.alignment === 'end') alignment = anchor.x + anchor.width - reference.width;
        return defineRect({
          x: alignment,
          y: reference.y,
          width: reference.width,
          height: reference.height,
        });
      }
      case 'left':
      case 'right': {
        let alignment = anchor.y;
        if (this.alignment === 'center') alignment = anchor.y + anchor.height / 2 - reference.height / 2;
        else if (this.alignment === 'end') alignment = anchor.y + anchor.height - reference.height;
        return defineRect({
          x: reference.x,
          y: alignment,
          width: reference.width,
          height: reference.height,
        });
      }
      default:
        throw `Unable align at the quadrum, ${direction}`;
    }
  }

  /**
   * Checks if the big rect can contain the small rect dimensions.
   * @param {Object} big - Larger rect object
   * @param {Object} small - Smaller rect object
   * @returns {boolean} True if big rect can contain small rect
   */
  biggerRectThan(big, small) {
    return big.height >= small.height && big.width >= small.width;
  }

  /**
   * Starts observing configured events for flipping.
   */
  observe() {
    this.events.forEach((event) => {
      window.addEventListener(event, this.flip, true);
    });
  }

  /**
   * Stops observing events for flipping.
   */
  unobserve() {
    this.events.forEach((event) => {
      window.removeEventListener(event, this.flip, true);
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
      flip: context.flip.bind(context),
    });
  }
}

/**
 * Factory function to create and attach a Flipper plumber to a controller.
 * @param {Object} controller - Stimulus controller instance
 * @param {Object} [options] - Configuration options
 * @returns {Flipper} Flipper plumber instance
 */
export const attachFlipper = (controller, options) => new Flipper(controller, options);
