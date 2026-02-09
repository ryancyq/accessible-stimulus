/**
 * ARIA utilities for accessible components
 */

/**
 * Announce a message to screen readers using an aria-live region
 */
export function announce(message, options = {}) {
  const {
    politeness = 'polite',
    atomic = true,
    relevant = 'additions text',
  } = options;

  // Find or create live region
  let liveRegion = document.querySelector(
    `[data-live-region="${politeness}"]`
  );

  if (!liveRegion) {
    liveRegion = document.createElement('div');
    liveRegion.setAttribute('data-live-region', politeness);
    liveRegion.setAttribute('aria-live', politeness);
    liveRegion.setAttribute('aria-atomic', atomic.toString());
    liveRegion.setAttribute('aria-relevant', relevant);
    liveRegion.className = 'sr-only';
    document.body.appendChild(liveRegion);
  }

  // Clear and set new message
  liveRegion.textContent = '';
  setTimeout(() => {
    liveRegion.textContent = message;
  }, 100);
}

/**
 * Generate a unique ID for ARIA relationships
 */
export function generateId(prefix = 'a11y') {
  return `${prefix}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Set up ARIA relationship between elements
 */
export function setAriaRelationship(element, attribute, targetId) {
  element.setAttribute(attribute, targetId);
}

/**
 * Ensure element has an ID, generate one if needed
 */
export function ensureId(element, prefix = 'element') {
  if (!element.id) {
    element.id = generateId(prefix);
  }
  return element.id;
}

/**
 * Update aria-expanded state
 */
export function setExpanded(element, expanded) {
  element.setAttribute('aria-expanded', expanded.toString());
}

/**
 * Update aria-pressed state
 */
export function setPressed(element, pressed) {
  element.setAttribute('aria-pressed', pressed.toString());
}

/**
 * Update aria-checked state
 */
export function setChecked(element, checked) {
  element.setAttribute('aria-checked', checked.toString());
}

/**
 * Update aria-disabled state
 */
export function setDisabled(element, disabled) {
  element.setAttribute('aria-disabled', disabled.toString());
  if (disabled) {
    element.setAttribute('tabindex', '-1');
  } else {
    element.removeAttribute('tabindex');
  }
}
