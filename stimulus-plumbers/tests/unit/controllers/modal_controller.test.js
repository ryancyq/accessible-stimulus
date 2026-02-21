import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import { visibilityConfig } from '../../../src/plumbers/plumber/support'  
import ModalController from '../../../src/controllers/modal_controller';

describe('ModalController', () => {
  let application;
  let isVisibleOnlySpy;
  let consoleErrorSpy;

  beforeEach(() => {
    application = Application.start();
    application.register('modal', ModalController);
    isVisibleOnlySpy = vi.spyOn(visibilityConfig, 'visibleOnly', 'get').mockReturnValue(false);
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    document.body.style.overflow = '';
    consoleErrorSpy.mockRestore();
    isVisibleOnlySpy.mockRestore();
  });

  describe('guardrails', () => {
    it('logs error when modal target is missing', async () => {
      document.body.innerHTML = '<div data-controller="modal"></div>';
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'ModalController requires a modal target. Add data-modal-target="modal" to your element.'
      );
    });

    it('does not operate when modal target is missing', () => {
      document.body.innerHTML = `
        <div data-controller="modal">
          <button data-action="modal#open">Open</button>
        </div>
      `;

      document.querySelector('button').click();
      expect(document.body.style.overflow).toBe('');
    });
  });

  describe('native dialog element', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="modal">
          <button data-action="modal#open">Open</button>
          <dialog data-modal-target="modal">
            <button data-action="modal#close">Close</button>
          </dialog>
        </div>
      `;

      const dialog = document.querySelector('dialog');
      dialog.showModal = vi.fn();
      dialog.close = vi.fn();
    });

    it('uses showModal() to open', () => {
      const dialog = document.querySelector('dialog');
      document.querySelector('[data-action="modal#open"]').click();

      expect(dialog.showModal).toHaveBeenCalled();
    });

    it('uses close() to close', () => {
      const dialog = document.querySelector('dialog');
      document.querySelector('[data-action="modal#open"]').click();
      document.querySelector('[data-action="modal#close"]').click();

      expect(dialog.close).toHaveBeenCalled();
    });

    it('restores focus after closing', async () => {
      const openButton = document.querySelector('[data-action="modal#open"]');
      openButton.focus();
      openButton.click();

      await new Promise(resolve => setTimeout(resolve, 10));
      document.querySelector('[data-action="modal#close"]').click();
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(document.activeElement).toBe(openButton);
    });

    it('closes on backdrop click', () => {
      const dialog = document.querySelector('dialog');
      dialog.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 100, bottom: 300, right: 300
      }));

      document.querySelector('[data-action="modal#open"]').click();
      dialog.dispatchEvent(new MouseEvent('click', {
        bubbles: true, clientX: 0, clientY: 0
      }));

      expect(dialog.close).toHaveBeenCalled();
    });

    it('does not close on content click', () => {
      const dialog = document.querySelector('dialog');
      dialog.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 100, bottom: 300, right: 300
      }));

      document.querySelector('[data-action="modal#open"]').click();
      dialog.close.mockClear();

      dialog.dispatchEvent(new MouseEvent('click', {
        bubbles: true, clientX: 200, clientY: 200
      }));

      expect(dialog.close).not.toHaveBeenCalled();
    });
  });

  describe('custom implementation', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="modal">
          <button data-action="modal#open">Open</button>
          <div data-modal-target="overlay" hidden>
            <div data-modal-target="modal" role="dialog" aria-modal="true">
              <button data-action="modal#close">Close</button>
            </div>
          </div>
        </div>
      `;
    });

    it('shows and hides overlay', () => {
      const overlay = document.querySelector('[data-modal-target="overlay"]');
      const openButton = document.querySelector('[data-action="modal#open"]');
      const closeButton = document.querySelector('[data-action="modal#close"]');

      expect(overlay.hidden).toBe(true);
      openButton.click();
      expect(overlay.hidden).toBe(false);
      closeButton.click();
      expect(overlay.hidden).toBe(true);
    });

    it('prevents and restores body scroll', () => {
      const openButton = document.querySelector('[data-action="modal#open"]');
      const closeButton = document.querySelector('[data-action="modal#close"]');

      expect(document.body.style.overflow).toBe('');
      openButton.click();
      expect(document.body.style.overflow).toBe('hidden');
      closeButton.click();
      expect(document.body.style.overflow).toBe('');
    });

    it('closes on overlay click, not on content click', () => {
      const overlay = document.querySelector('[data-modal-target="overlay"]');
      const modal = document.querySelector('[data-modal-target="modal"]');
      const openButton = document.querySelector('[data-action="modal#open"]');

      openButton.click();
      modal.click();
      expect(overlay.hidden).toBe(false);

      overlay.click();
      expect(overlay.hidden).toBe(true);
    });

    it('restores focus after closing', async () => {
      const openButton = document.querySelector('[data-action="modal#open"]');
      openButton.focus();
      openButton.click();

      await new Promise(resolve => setTimeout(resolve, 10));
      document.querySelector('[data-action="modal#close"]').click();
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(document.activeElement).toBe(openButton);
    });

  });

  describe('custom implementation without overlay', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="modal">
          <button data-action="modal#open">Open</button>
          <div data-modal-target="modal" role="dialog" aria-modal="true" hidden>
            <button data-action="modal#close">Close</button>
          </div>
        </div>
      `;
    });

    it('shows and hides modal directly when no overlay', () => {
      const modal = document.querySelector('[data-modal-target="modal"]');
      const openButton = document.querySelector('[data-action="modal#open"]');
      const closeButton = document.querySelector('[data-action="modal#close"]');

      expect(modal.hidden).toBe(true);
      openButton.click();
      expect(modal.hidden).toBe(false);
      closeButton.click();
      expect(modal.hidden).toBe(true);
    });
  });

  describe('accessibility', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="modal">
          <button data-action="modal#open">Open</button>
          <div data-modal-target="overlay" hidden>
            <div data-modal-target="modal" role="dialog" aria-modal="true">
              <button data-action="modal#close">Close</button>
            </div>
          </div>
        </div>
      `;
    });

    it('announces open and close to screen readers', async () => {
      document.querySelector('[data-action="modal#open"]').click();
      await new Promise(resolve => setTimeout(resolve, 150));

      let liveRegion = document.querySelector('[data-live-region="polite"]');
      expect(liveRegion.textContent).toBe('Modal opened');

      document.querySelector('[data-action="modal#close"]').click();
      await new Promise(resolve => setTimeout(resolve, 150));

      expect(liveRegion.textContent).toBe('Modal closed');
    });
  });
});
