/**
 * Test setup for Vitest
 */

import { expect, afterEach } from 'vitest';
import { cleanup } from '@testing-library/dom';

// Cleanup after each test
afterEach(() => {
  cleanup();
  document.body.innerHTML = '';
});

// Add custom matchers if needed
expect.extend({
  toBeAccessible(element: HTMLElement) {
    // Basic accessibility checks
    const hasRole = element.hasAttribute('role') || element.tagName !== 'DIV';
    const hasLabel =
      element.hasAttribute('aria-label') ||
      element.hasAttribute('aria-labelledby') ||
      element.textContent?.trim() !== '';

    return {
      pass: hasRole && hasLabel,
      message: () =>
        `Expected element to be accessible with proper role and labeling`,
    };
  },
});
