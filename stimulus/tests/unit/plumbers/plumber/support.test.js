import { describe, it, expect, beforeEach } from 'vitest'
import {
  defineRect,
  directionMap,
  viewportRect,
  isWithinViewport,
  isValidDate,
  tryParseDate,
} from '../../../../src/plumbers/plumber/support'

describe('support utilities', () => {
  describe('defineRect', () => {
    it('creates a rect object with proper properties', () => {
      const rect = defineRect({ x: 10, y: 20, width: 100, height: 50 })

      expect(rect).toEqual({
        x: 10,
        y: 20,
        width: 100,
        height: 50,
        left: 10,
        right: 110,
        top: 20,
        bottom: 70,
      })
    })

    it('handles zero values', () => {
      const rect = defineRect({ x: 0, y: 0, width: 0, height: 0 })

      expect(rect).toEqual({
        x: 0,
        y: 0,
        width: 0,
        height: 0,
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
      })
    })

    it('handles negative values', () => {
      const rect = defineRect({ x: -10, y: -20, width: 100, height: 50 })

      expect(rect.left).toBe(-10)
      expect(rect.right).toBe(90)
      expect(rect.top).toBe(-20)
      expect(rect.bottom).toBe(30)
    })
  })

  describe('directionMap', () => {
    it('maps opposite directions correctly', () => {
      expect(directionMap.top).toBe('bottom')
      expect(directionMap.bottom).toBe('top')
      expect(directionMap.left).toBe('right')
      expect(directionMap.right).toBe('left')
    })
  })

  describe('viewportRect', () => {
    it('returns viewport dimensions as a rect', () => {
      const rect = viewportRect()

      expect(rect.x).toBe(0)
      expect(rect.y).toBe(0)
      expect(rect.width).toBe(window.innerWidth)
      expect(rect.height).toBe(window.innerHeight)
    })

    it('uses documentElement dimensions when window dimensions unavailable', () => {
      const originalInnerWidth = window.innerWidth
      const originalInnerHeight = window.innerHeight

      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: undefined,
      })
      Object.defineProperty(window, 'innerHeight', {
        writable: true,
        configurable: true,
        value: undefined,
      })

      const rect = viewportRect()

      expect(rect.width).toBe(document.documentElement.clientWidth)
      expect(rect.height).toBe(document.documentElement.clientHeight)

      // Restore
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: originalInnerWidth,
      })
      Object.defineProperty(window, 'innerHeight', {
        writable: true,
        configurable: true,
        value: originalInnerHeight,
      })
    })
  })

  describe('isWithinViewport', () => {
    beforeEach(() => {
      document.body.innerHTML = ''
    })

    it('returns false for non-HTMLElement', () => {
      expect(isWithinViewport(null)).toBe(false)
      expect(isWithinViewport(undefined)).toBe(false)
      expect(isWithinViewport({})).toBe(false)
    })

    it('returns true for element fully within viewport', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)

      // Mock getBoundingClientRect
      element.getBoundingClientRect = () => ({
        top: 100,
        left: 100,
        width: 200,
        height: 200,
      })

      expect(isWithinViewport(element)).toBe(true)
    })

    it('returns false for element completely outside viewport (top)', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)

      element.getBoundingClientRect = () => ({
        top: -300,
        left: 100,
        width: 200,
        height: 200,
      })

      expect(isWithinViewport(element)).toBe(false)
    })

    it('returns false for element completely outside viewport (left)', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)

      element.getBoundingClientRect = () => ({
        top: 100,
        left: -300,
        width: 200,
        height: 200,
      })

      expect(isWithinViewport(element)).toBe(false)
    })

    it('returns true for partially visible element', () => {
      const element = document.createElement('div')
      document.body.appendChild(element)

      element.getBoundingClientRect = () => ({
        top: -50,
        left: -50,
        width: 200,
        height: 200,
      })

      expect(isWithinViewport(element)).toBe(true)
    })
  })

  describe('isValidDate', () => {
    it('returns true for valid Date objects', () => {
      expect(isValidDate(new Date())).toBe(true)
      expect(isValidDate(new Date('2024-01-01'))).toBe(true)
      expect(isValidDate(new Date(2024, 0, 1))).toBe(true)
    })

    it('returns false for invalid Date objects', () => {
      expect(isValidDate(new Date('invalid'))).toBe(false)
      expect(isValidDate(new Date(NaN))).toBe(false)
    })

    it('returns false for non-Date values', () => {
      expect(isValidDate(null)).toBe(false)
      expect(isValidDate(undefined)).toBe(false)
      expect(isValidDate('2024-01-01')).toBe(false)
      expect(isValidDate(1234567890)).toBe(false)
      expect(isValidDate({})).toBe(false)
    })
  })

  describe('tryParseDate', () => {
    it('throws when no values provided', () => {
      expect(() => tryParseDate()).toThrow('Missing values to parse as date')
    })

    it('parses a single valid date string', () => {
      const result = tryParseDate('2024-01-15')
      expect(result).toBeInstanceOf(Date)
      expect(result.getFullYear()).toBe(2024)
      expect(result.getMonth()).toBe(0)
      expect(result.getDate()).toBe(15)
    })

    it('parses a single valid timestamp', () => {
      const timestamp = new Date('2024-01-15').getTime()
      const result = tryParseDate(timestamp)
      expect(result).toBeInstanceOf(Date)
      expect(result.getFullYear()).toBe(2024)
      expect(result.getMonth()).toBe(0)
      expect(result.getDate()).toBe(15)
    })

    it('returns undefined for single invalid value', () => {
      expect(tryParseDate('invalid')).toBeUndefined()
      expect(tryParseDate(null)).toBeUndefined()
    })

    it('parses multiple values as Date constructor arguments', () => {
      const result = tryParseDate(2024, 0, 15)
      expect(result).toBeInstanceOf(Date)
      expect(result.getFullYear()).toBe(2024)
      expect(result.getMonth()).toBe(0)
      expect(result.getDate()).toBe(15)
    })

    it('returns undefined for invalid multiple values', () => {
      expect(tryParseDate('invalid', 'date')).toBeUndefined()
    })

    it('handles Date objects passed as single value', () => {
      const date = new Date('2024-01-15')
      const result = tryParseDate(date)
      expect(result).toBeInstanceOf(Date)
      expect(result.getTime()).toBe(date.getTime())
    })
  })
})
