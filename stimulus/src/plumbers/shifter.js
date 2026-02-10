import Plumber from './plumber';
import { viewportRect, directionMap, defineRect } from './plumber/support';

const defaultOptions = {
  events: ['resize'],
  boundaries: ['top', 'left', 'right'],
  onShifted: 'shifted',
};

export class Shifter extends Plumber {
  /**
   * Creates a new Shifter plumber instance for viewport boundary shifting.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} [options] - Configuration options
   * @param {string[]} [options.events=['resize']] - Events triggering shift calculation
   * @param {string[]} [options.boundaries=['top','left','right']] - Boundaries to check (valid values: 'top', 'bottom', 'left', 'right')
   * @param {string} [options.onShifted='shifted'] - Callback name when shifted
   */
  constructor(controller, options = {}) {
    super(controller, options);

    const { onShifted, events, boundaries } = Object.assign({}, defaultOptions, options);
    this.onShifted = onShifted;
    this.events = events;
    this.boundaries = boundaries;

    this.enhance();
    this.observe();
  }

  /**
   * Calculates and applies transform to shift element within viewport boundaries.
   * @returns {Promise<void>}
   */
  shift = async () => {
    if (!this.visible) return;

    this.dispatch('shift');
    const overflow = this.overflowRect(this.element.getBoundingClientRect(), this.elementTranslations(this.element));
    const translateX = overflow['left'] || overflow['right'] || 0;
    const translateY = overflow['top'] || overflow['bottom'] || 0;
    this.element.style.transform = `translate(${translateX}px, ${translateY}px)`;

    await this.awaitCallback('onShifted', overflow);
    this.dispatch('shifted', { detail: overflow });
  };

  /**
   * Calculates overflow distances for each boundary direction.
   * @param {DOMRect} targetRect - Target element's bounding rect
   * @param {Object} translations - Current transform translations
   * @returns {Object} Overflow distances by direction
   */
  overflowRect(targetRect, translations) {
    const overflow = {};
    const viewport = viewportRect();
    const currentRect = defineRect({
      x: targetRect.x - translations.x,
      y: targetRect.y - translations.y,
      width: targetRect.width,
      height: targetRect.height,
    });
    for (const direction of this.boundaries) {
      const distance = this.directionDistance(currentRect, direction, viewport);
      const opposite = directionMap[direction];
      if (distance < 0) {
        const sufficientSpace = currentRect[opposite] + distance >= viewport[opposite];
        if (sufficientSpace && !overflow[opposite]) overflow[direction] = distance;
      } else {
        overflow[direction] = '';
      }
    }
    return overflow;
  }

  /**
   * Calculates distance from inner rect to outer boundary in given direction.
   * @param {Object} inner - Inner rect object
   * @param {string} direction - Direction ('top', 'bottom', 'left', 'right')
   * @param {Object} outer - Outer rect object
   * @returns {number} Distance to boundary (negative if overflowing)
   * @throws {string} If direction is invalid
   */
  directionDistance(inner, direction, outer) {
    switch (direction) {
      case 'top':
      case 'left':
        return inner[direction] - outer[direction];
      case 'bottom':
      case 'right':
        return outer[direction] - inner[direction];
      default:
        throw `Invalid direction to calcuate distance, ${direction}`;
    }
  }

  /**
   * Extracts current translate values from element's transform style.
   * @param {HTMLElement} target - Target element
   * @returns {Object} Translation object with x and y values
   */
  elementTranslations(target) {
    const style = window.getComputedStyle(target);
    const matrix = style['transform'] || style['webkitTransform'] || style['mozTransform'];

    if (matrix === 'none' || typeof matrix === 'undefined') {
      return { x: 0, y: 0 };
    }

    const matrixType = matrix.includes('3d') ? '3d' : '2d';
    const matrixValues = matrix.match(/matrix.*\((.+)\)/)[1].split(', ');

    if (matrixType === '2d') {
      return { x: Number(matrixValues[4]), y: Number(matrixValues[5]) };
    }
    return { x: 0, y: 0 };
  }

  /**
   * Starts observing configured events for shifting.
   */
  observe() {
    this.events.forEach((event) => {
      window.addEventListener(event, this.shift, true);
    });
  }

  /**
   * Stops observing events for shifting.
   */
  unobserve() {
    this.events.forEach((event) => {
      window.removeEventListener(event, this.shift, true);
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
      shift: context.shift.bind(context),
    });
  }
}

/**
 * Factory function to create and attach a Shifter plumber to a controller.
 * @param {Object} controller - Stimulus controller instance
 * @param {Object} [options] - Configuration options
 * @returns {Shifter} Shifter plumber instance
 */
export const attachShifter = (controller, options) => new Shifter(controller, options);
