import Plumber from './plumber';
import { viewportRect, directionMap, defineRect } from './plumber/support';

const defaultOptions = {
  events: ['resize'],
  boundaries: ['top', 'left', 'right'],
  onShifted: 'shifted',
};

export class Shifter extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);

    const { onShifted, events, boundaries } = Object.assign({}, defaultOptions, options);
    this.onShifted = onShifted;
    this.events = events;
    this.boundaries = boundaries;

    this.enhance();
    this.observe();
  }

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

  overflowRect(targetRect, translations) {
    const overflow = {};
    const viewport = viewportRect();
    const currentRect = defineRect({
      x: targetRect.x - translations.x,
      y: targetRect.y - translations.y,
      width: targetRect.width,
      height: targetRect.width,
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

  observe() {
    this.events.forEach((event) => {
      window.addEventListener(event, this.shift, true);
    });
  }

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

export const attachShifter = (controller, options) => new Shifter(controller, options);
