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

export function viewportRect() {
  return defineRect({
    x: 0,
    y: 0,
    width: window.innerWidth || document.documentElement.clientWidth,
    height: window.innerHeight || document.documentElement.clientHeight,
  });
}

export function isWithinViewport(target) {
  if (!(target instanceof HTMLElement)) return false;

  const outer = viewportRect();
  const inner = target.getBoundingClientRect();
  const vertical = inner.top <= outer.height && inner.top + inner.height > 0;
  const horizontal = inner.left <= outer.width && inner.left + inner.width > 0;
  return vertical && horizontal;
}

export function isValidDate(value) {
  return value instanceof Date && !isNaN(value);
}

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
