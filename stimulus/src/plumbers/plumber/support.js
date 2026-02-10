/**
 * Creates a rect object with position and dimension properties.
 * @param {Object} params - Rectangle parameters
 * @param {number} params.x - X coordinate
 * @param {number} params.y - Y coordinate
 * @param {number} params.width - Width
 * @param {number} params.height - Height
 * @returns {Object} Rect object with x, y, width, height, left, right, top, bottom properties
 */
export function defineRect({ x, y, width, height }) {
  return {
    x: x,
    y: y,
    width: width,
    height: height,
    left: x,
    right: x + width,
    top: y,
    bottom: y + height,
  };
}

export const directionMap = {
  top: 'bottom',
  bottom: 'top',
  left: 'right',
  right: 'left',
};

/**
 * Returns the current viewport dimensions as a rect object.
 * @returns {Object} Viewport rect with dimensions and boundaries
 */
export function viewportRect() {
  return defineRect({
    x: 0,
    y: 0,
    width: window.innerWidth || document.documentElement.clientWidth,
    height: window.innerHeight || document.documentElement.clientHeight,
  });
}

/**
 * Checks if an element is within the visible viewport.
 * @param {HTMLElement} target - Element to check
 * @returns {boolean} True if element is within viewport
 */
export function isWithinViewport(target) {
  if (!(target instanceof HTMLElement)) return false;

  const outer = viewportRect();
  const inner = target.getBoundingClientRect();
  const vertical = inner.top <= outer.height && inner.top + inner.height > 0;
  const horizontal = inner.left <= outer.width && inner.left + inner.width > 0;
  return vertical && horizontal;
}

/**
 * Validates if a value is a valid Date object.
 * @param {*} value - Value to check
 * @returns {boolean} True if value is a valid Date
 */
export function isValidDate(value) {
  return value instanceof Date && !isNaN(value);
}

/**
 * Attempts to parse values into a Date object.
 * @param {...*} values - Date values to parse
 * @returns {Date|undefined} Parsed Date object or undefined if invalid
 * @throws {string} If no values provided
 */
export function tryParseDate(...values) {
  if (values.length === 0) throw 'Missing values to parse as date';
  if (values.length === 1) {
    const parsed = new Date(values[0]);
    if (values[0] && isValidDate(parsed)) return parsed;
  } else {
    const parsed = new Date(...values);
    if (isValidDate(parsed)) return parsed;
  }
}
