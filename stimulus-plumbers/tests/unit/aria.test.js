import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { connectTriggerToTarget, disconnectTriggerFromTarget } from '../../src/aria.js';

describe('ARIA utilities', () => {
  let trigger;
  let target;

  beforeEach(() => {
    trigger = document.createElement('button');
    trigger.id = 'trigger';
    target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(trigger);
    document.body.appendChild(target);
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('connectTriggerToTarget', () => {
    it('sets role on target element', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(target.getAttribute('role')).toBe('menu');
    });

    it('sets aria-controls on trigger', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.getAttribute('aria-controls')).toBe('target');
    });

    it('sets aria-haspopup for menu role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.getAttribute('aria-haspopup')).toBe('menu');
    });

    it('sets aria-haspopup for dialog role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'dialog'
      });

      expect(trigger.getAttribute('aria-haspopup')).toBe('dialog');
    });

    it('sets aria-haspopup for listbox role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'listbox'
      });

      expect(trigger.getAttribute('aria-haspopup')).toBe('listbox');
    });

    it('sets aria-describedby for tooltip role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'tooltip'
      });

      expect(trigger.getAttribute('aria-describedby')).toBe('target');
    });

    it('does not override existing role by default', () => {
      target.setAttribute('role', 'existing');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(target.getAttribute('role')).toBe('existing');
    });

    it('overrides existing role with override option', () => {
      target.setAttribute('role', 'existing');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu',
        override: true
      });

      expect(target.getAttribute('role')).toBe('menu');
    });

    it('does not override existing aria-controls by default', () => {
      trigger.setAttribute('aria-controls', 'existing');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.getAttribute('aria-controls')).toBe('existing');
    });

    it('returns object with set attributes separated by element', () => {
      const result = connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(result).toEqual({
        trigger: {
          'aria-controls': 'target',
          'aria-haspopup': 'menu'
        },
        target: {
          role: 'menu'
        }
      });
    });

    it('handles missing trigger gracefully', () => {
      const result = connectTriggerToTarget({
        trigger: null,
        target,
        role: 'menu'
      });

      expect(result).toEqual({ trigger: {}, target: {} });
    });

    it('handles missing target gracefully', () => {
      const result = connectTriggerToTarget({
        trigger,
        target: null,
        role: 'menu'
      });

      expect(result).toEqual({ trigger: {}, target: {} });
    });

    it('requires target id for aria-controls', () => {
      target.removeAttribute('id');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.hasAttribute('aria-controls')).toBe(false);
    });

    it('works without specifying role', () => {
      const result = connectTriggerToTarget({
        trigger,
        target
      });

      expect(trigger.getAttribute('aria-controls')).toBe('target');
      expect(result.trigger['aria-controls']).toBe('target');
    });
  });

  describe('disconnectTriggerFromTarget', () => {
    beforeEach(() => {
      trigger.setAttribute('aria-controls', 'target');
      trigger.setAttribute('aria-haspopup', 'menu');
      trigger.setAttribute('aria-describedby', 'target');
      target.setAttribute('role', 'menu');
    });

    it('removes all ARIA relationship attributes by default', () => {
      disconnectTriggerFromTarget({ trigger, target });

      expect(trigger.hasAttribute('aria-controls')).toBe(false);
      expect(trigger.hasAttribute('aria-haspopup')).toBe(false);
      expect(trigger.hasAttribute('aria-describedby')).toBe(false);
      expect(target.hasAttribute('role')).toBe(false);
    });

    it('removes specific attributes when specified', () => {
      disconnectTriggerFromTarget({
        trigger,
        target,
        attributes: ['aria-controls']
      });

      expect(trigger.hasAttribute('aria-controls')).toBe(false);
      expect(trigger.hasAttribute('aria-haspopup')).toBe(true);
      expect(trigger.hasAttribute('aria-describedby')).toBe(true);
      expect(target.hasAttribute('role')).toBe(true);
    });

    it('removes role when explicitly specified', () => {
      disconnectTriggerFromTarget({
        trigger,
        target,
        attributes: ['role']
      });

      expect(target.hasAttribute('role')).toBe(false);
      expect(trigger.hasAttribute('aria-controls')).toBe(true);
    });

    it('handles missing trigger gracefully', () => {
      expect(() => {
        disconnectTriggerFromTarget({ trigger: null, target });
      }).not.toThrow();
    });

    it('handles missing target gracefully', () => {
      expect(() => {
        disconnectTriggerFromTarget({ trigger, target: null });
      }).not.toThrow();
    });
  });
});
