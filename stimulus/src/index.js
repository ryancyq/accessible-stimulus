/**
 * @accessible-stimulus/controllers
 *
 * Accessible Stimulus controllers for UI components
 * Following WCAG 2.1+ and WAI-ARIA best practices
 */

// Export utilities (framework-agnostic)
export * from './focus.js';
export * from './keyboard.js';
export * from './aria.js';

// Export Stimulus controllers
export { default as DialogController } from './controllers/dialog_controller.js';
