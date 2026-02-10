import { describe, it, expect, beforeEach, vi } from 'vitest'
import {
  Visibility,
  attachVisibility,
  toggleVisibility,
  visibilityConfig,
} from '../../../src/plumbers/visibility'

describe('Visibility', () => {
  let mockController
  let element

  beforeEach(() => {
    element = document.createElement('div')
    document.body.appendChild(element)

    mockController = {
      identifier: 'visibility',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    // Reset visibility config
    visibilityConfig.hiddenClass = 'hidden'

    // Mock getBoundingClientRect for visibility checks
    element.getBoundingClientRect = () => ({
      top: 100,
      left: 100,
      width: 200,
      height: 200,
    })
  })

  describe('toggleVisibility', () => {
    it('adds hidden class when hiding with class-based visibility', () => {
      toggleVisibility(element, false, 'hidden')

      expect(element.classList.contains('hidden')).toBe(true)
    })

    it('removes hidden class when showing with class-based visibility', () => {
      element.classList.add('hidden')
      toggleVisibility(element, true, 'hidden')

      expect(element.classList.contains('hidden')).toBe(false)
    })

    it('sets hidden attribute when hiding without class', () => {
      visibilityConfig.hiddenClass = null
      toggleVisibility(element, false, null)

      expect(element.hasAttribute('hidden')).toBe(true)
    })

    it('removes hidden attribute when showing without class', () => {
      visibilityConfig.hiddenClass = null
      element.setAttribute('hidden', true)
      toggleVisibility(element, true, null)

      expect(element.hasAttribute('hidden')).toBe(false)
    })

    it('uses global config when hiddenClass not provided', () => {
      visibilityConfig.hiddenClass = 'custom-hidden'
      toggleVisibility(element, false)

      expect(element.classList.contains('custom-hidden')).toBe(true)
    })

    it('does nothing for non-HTMLElement', () => {
      expect(() => toggleVisibility(null, false)).not.toThrow()
      expect(() => toggleVisibility(undefined, true)).not.toThrow()
    })
  })

  describe('constructor', () => {
    it('initializes with default options', () => {
      const visibility = new Visibility(mockController)

      expect(visibility.controller).toBe(mockController)
      expect(visibility.visibility).toBe('visibility')
      expect(visibility.visibilityResolver).toBe('isVisible')
      expect(visibility.onShown).toBe('shown')
      expect(visibility.onHidden).toBe('hidden')
    })

    it('accepts custom visibility namespace', () => {
      const visibility = new Visibility(mockController, {
        visibility: 'customNamespace',
      })

      expect(visibility.visibility).toBe('customNamespace')
    })

    it('accepts custom callbacks', () => {
      const visibility = new Visibility(mockController, {
        onShown: 'customShown',
        onHidden: 'customHidden',
      })

      expect(visibility.onShown).toBe('customShown')
      expect(visibility.onHidden).toBe('customHidden')
    })

    it('enhances controller with visibility helpers', () => {
      const visibility = new Visibility(mockController)

      expect(mockController.visibility).toBeDefined()
      expect(mockController.visibility.show).toBeTypeOf('function')
      expect(mockController.visibility.hide).toBeTypeOf('function')
      expect(mockController.visibility.isVisible).toBeTypeOf('function')
    })
  })

  describe('isVisible', () => {
    it('returns false for non-HTMLElement', () => {
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(null)).toBe(false)
      expect(visibility.isVisible(undefined)).toBe(false)
      expect(visibility.isVisible({})).toBe(false)
    })

    it('returns true when element does not have hidden class', () => {
      visibilityConfig.hiddenClass = 'hidden'
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(element)).toBe(true)
    })

    it('returns false when element has hidden class', () => {
      visibilityConfig.hiddenClass = 'hidden'
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(element)).toBe(false)
    })

    it('checks hidden attribute when no hiddenClass configured', () => {
      visibilityConfig.hiddenClass = null
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(element)).toBe(true)

      element.setAttribute('hidden', true)
      expect(visibility.isVisible(element)).toBe(false)
    })
  })

  describe('show', () => {
    it('does nothing when element is already visible', async () => {
      const visibility = new Visibility(mockController)

      await visibility.show()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('dispatches show and shown events', async () => {
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      await visibility.show()

      expect(mockController.dispatch).toHaveBeenCalledWith('show', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('shown', expect.any(Object))
    })

    it('removes hidden class', async () => {
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      await visibility.show()

      expect(element.classList.contains('hidden')).toBe(false)
    })

    it('calls onShown callback', async () => {
      element.classList.add('hidden')
      const onShown = vi.fn()
      mockController.shown = onShown
      const visibility = new Visibility(mockController, { onShown: 'shown' })

      await visibility.show()

      expect(onShown).toHaveBeenCalledWith({ target: element })
    })

    it('awaits async onShown callback', async () => {
      element.classList.add('hidden')
      const onShown = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 10)))
      mockController.shown = onShown
      const visibility = new Visibility(mockController, { onShown: 'shown' })

      await visibility.show()

      expect(onShown).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('shown', expect.any(Object))
    })

    it('does nothing for non-HTMLElement', async () => {
      const visibility = new Visibility(mockController, { element: null })

      await visibility.show()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('hide', () => {
    it('does nothing when element is already hidden', async () => {
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      await visibility.hide()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('dispatches hide and hidden events', async () => {
      const visibility = new Visibility(mockController)

      await visibility.hide()

      expect(mockController.dispatch).toHaveBeenCalledWith('hide', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('hidden', expect.any(Object))
    })

    it('adds hidden class', async () => {
      const visibility = new Visibility(mockController)

      await visibility.hide()

      expect(element.classList.contains('hidden')).toBe(true)
    })

    it('calls onHidden callback', async () => {
      const onHidden = vi.fn()
      mockController.hidden = onHidden
      const visibility = new Visibility(mockController, { onHidden: 'hidden' })

      await visibility.hide()

      expect(onHidden).toHaveBeenCalledWith({ target: element })
    })

    it('awaits async onHidden callback', async () => {
      const onHidden = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 10)))
      mockController.hidden = onHidden
      const visibility = new Visibility(mockController, { onHidden: 'hidden' })

      await visibility.hide()

      expect(onHidden).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('hidden', expect.any(Object))
    })

    it('does nothing for non-HTMLElement', async () => {
      mockController.element = null
      const visibility = new Visibility(mockController, { element: null })

      await visibility.hide()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('enhance', () => {
    it('adds show and hide methods to controller', () => {
      const visibility = new Visibility(mockController)

      expect(mockController.visibility.show).toBeTypeOf('function')
      expect(mockController.visibility.hide).toBeTypeOf('function')
    })

    it('adds visible getter to controller', () => {
      const visibility = new Visibility(mockController)

      expect(mockController.visibility.visible).toBe(true)

      element.classList.add('hidden')
      expect(mockController.visibility.visible).toBe(false)
    })

    it('adds custom visibility resolver to controller', () => {
      const visibility = new Visibility(mockController)

      expect(mockController.visibility.isVisible).toBeTypeOf('function')
      expect(mockController.visibility.isVisible(element)).toBe(true)

      element.classList.add('hidden')
      expect(mockController.visibility.isVisible(element)).toBe(false)
    })

    it('uses custom namespace', () => {
      const visibility = new Visibility(mockController, {
        visibility: 'customVis',
      })

      expect(mockController.customVis).toBeDefined()
      expect(mockController.customVis.show).toBeTypeOf('function')
      expect(mockController.customVis.hide).toBeTypeOf('function')
    })
  })

  describe('attachVisibility', () => {
    it('creates and returns a Visibility instance', () => {
      const visibility = attachVisibility(mockController, {
        visibility: 'custom',
      })

      expect(visibility).toBeInstanceOf(Visibility)
      expect(visibility.visibility).toBe('custom')
    })
  })

  describe('integration', () => {
    it('can show and hide element using controller methods', async () => {
      const visibility = new Visibility(mockController)

      // Initially visible
      expect(mockController.visibility.visible).toBe(true)

      // Hide
      await mockController.visibility.hide()
      expect(element.classList.contains('hidden')).toBe(true)
      expect(mockController.visibility.visible).toBe(false)

      // Show
      await mockController.visibility.show()
      expect(element.classList.contains('hidden')).toBe(false)
      expect(mockController.visibility.visible).toBe(true)
    })

    it('works with attribute-based visibility', async () => {
      visibilityConfig.hiddenClass = null
      const visibility = new Visibility(mockController)

      await mockController.visibility.hide()
      expect(element.hasAttribute('hidden')).toBe(true)

      await mockController.visibility.show()
      expect(element.hasAttribute('hidden')).toBe(false)
    })
  })
})
