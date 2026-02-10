import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { ContentLoader, attachContentLoader } from '../../../src/plumbers/content-loader'

describe('ContentLoader', () => {
  let mockController
  let element

  beforeEach(() => {
    element = document.createElement('div')
    document.body.appendChild(element)

    mockController = {
      identifier: 'content-loader',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    // Mock getBoundingClientRect for visibility checks
    element.getBoundingClientRect = () => ({
      top: 100,
      left: 100,
      width: 200,
      height: 200,
    })

    // Mock fetch - return text as a non-awaited promise to match the implementation
    global.fetch = vi.fn(async () => ({
      text: () => Promise.resolve('<p>Loaded content</p>'),
    }))
  })

  afterEach(() => {
    vi.clearAllMocks()
    vi.restoreAllMocks()
  })

  describe('constructor', () => {
    it('initializes with default options', () => {
      const loader = new ContentLoader(mockController)

      expect(loader.controller).toBe(mockController)
      expect(loader.content).toBe(null)
      expect(loader.url).toBe('')
      expect(loader.reload).toBe('never')
      expect(loader.stale).toBe(3600)
      expect(loader.onLoad).toBeTypeOf('function')
      expect(loader.onLoading).toBeTypeOf('function')
      expect(loader.onLoaded).toBe('loaded')
    })

    it('accepts custom url', () => {
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })

      expect(loader.url).toBe('/api/content')
    })

    it('accepts custom reload option', () => {
      const loader = new ContentLoader(mockController, {
        reload: 'always',
      })

      expect(loader.reload).toBe('always')
    })

    it('accepts custom stale time', () => {
      const loader = new ContentLoader(mockController, {
        stale: 7200,
      })

      expect(loader.stale).toBe(7200)
    })

    it('accepts custom callbacks', () => {
      const loader = new ContentLoader(mockController, {
        onLoad: 'customLoad',
        onLoading: 'customLoading',
        onLoaded: 'customLoaded',
      })

      expect(loader.onLoad).toBe('customLoad')
      expect(loader.onLoading).toBe('customLoading')
      expect(loader.onLoaded).toBe('customLoaded')
    })

    it('enhances controller with load method', () => {
      const loader = new ContentLoader(mockController)

      expect(mockController.load).toBeTypeOf('function')
    })
  })

  describe('onLoad', () => {
    it('returns true when url is provided', async () => {
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })

      expect(await loader.onLoad({ url: '/api/content' })).toBe(true)
    })

    it('returns false when url is empty', async () => {
      const loader = new ContentLoader(mockController, {
        url: '',
      })

      expect(await loader.onLoad({ url: '' })).toBe(false)
    })

    it('can be overridden for custom loading conditions', async () => {
      const loader = new ContentLoader(mockController, {
        url: '',
      })
      loader.onLoad = vi.fn(async () => true)

      const result = await loader.onLoad({ url: '' })

      expect(loader.onLoad).toHaveBeenCalled()
      expect(result).toBe(true)
    })
  })

  describe('remoteLoader', () => {
    it('fetches content from url', async () => {
      const loader = new ContentLoader(mockController)

      const content = await loader.remoteLoader('/api/content')

      expect(global.fetch).toHaveBeenCalledWith('/api/content')
      expect(content).toBe('<p>Loaded content</p>')
    })
  })

  describe('localLoader', () => {
    it('returns empty string by default', async () => {
      const loader = new ContentLoader(mockController)

      const content = await loader.localLoader()

      expect(content).toBe('')
    })

    it('can be overridden to provide static content', async () => {
      const loader = new ContentLoader(mockController)
      loader.localLoader = vi.fn(async () => '<p>Static content</p>')

      const content = await loader.localLoader()

      expect(content).toBe('<p>Static content</p>')
    })
  })

  describe('reloadable', () => {
    it('returns false when reload is "never"', () => {
      const loader = new ContentLoader(mockController, {
        reload: 'never',
      })

      expect(loader.reloadable).toBe(false)
    })

    it('returns true when reload is "always"', () => {
      const loader = new ContentLoader(mockController, {
        reload: 'always',
      })

      expect(loader.reloadable).toBe(true)
    })

    it('returns false when no loadedAt timestamp exists', () => {
      const loader = new ContentLoader(mockController, {
        reload: 'stale',
      })

      expect(loader.reloadable).toBeFalsy()
    })
  })

  describe('load', () => {
    it('does nothing when onLoad returns false', async () => {
      const loader = new ContentLoader(mockController, {
        url: '',
      })

      await loader.load()

      expect(mockController.dispatch).toHaveBeenCalledWith('load', expect.any(Object))
      expect(mockController.dispatch).not.toHaveBeenCalledWith('loading', expect.any(Object))
      expect(global.fetch).not.toHaveBeenCalled()
    })

    it('does nothing when already loaded and reload is "never"', async () => {
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
        reload: 'never',
      })
      loader.loadedAt = Date.now()

      await loader.load()

      expect(global.fetch).not.toHaveBeenCalled()
    })

    it('dispatches load, loading, and loaded events', async () => {
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })

      await loader.load()

      expect(mockController.dispatch).toHaveBeenCalledWith('load', expect.objectContaining({
        detail: { url: '/api/content' },
      }))
      expect(mockController.dispatch).toHaveBeenCalledWith('loading', expect.objectContaining({
        detail: { url: '/api/content' },
      }))
      expect(mockController.dispatch).toHaveBeenCalledWith('loaded', expect.objectContaining({
        detail: expect.objectContaining({
          url: '/api/content',
          content: '<p>Loaded content</p>',
        }),
      }))
    })

    it('fetches content from url', async () => {
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })

      await loader.load()

      expect(global.fetch).toHaveBeenCalledWith('/api/content')
    })

    it('calls onLoad to check if loadable', async () => {
      const onLoad = vi.fn(async () => true)
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })
      loader.onLoad = onLoad

      await loader.load()

      expect(onLoad).toHaveBeenCalledWith({ url: '/api/content' })
    })

    it('calls onLoading to fetch content', async () => {
      const onLoading = vi.fn(async () => '<p>Custom content</p>')
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })
      loader.onLoading = onLoading

      await loader.load()

      expect(onLoading).toHaveBeenCalledWith({ url: '/api/content' })
    })

    it('calls onLoaded callback after fetching', async () => {
      const onLoaded = vi.fn()
      mockController.loaded = onLoaded
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
        onLoaded: 'loaded',
      })

      await loader.load()

      expect(onLoaded).toHaveBeenCalledWith(expect.objectContaining({
        url: '/api/content',
        content: '<p>Loaded content</p>',
      }))
    })

    it('sets loadedAt timestamp after loading', async () => {
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })

      const before = Date.now()
      await loader.load()
      const after = Date.now()

      expect(loader.loadedAt).toBeGreaterThanOrEqual(before)
      expect(loader.loadedAt).toBeLessThanOrEqual(after)
    })

    it('uses localLoader when no url provided', async () => {
      const loader = new ContentLoader(mockController, {
        url: '',
      })
      loader.onLoad = vi.fn(async () => true)
      loader.localLoader = vi.fn(async () => '<p>Static content</p>')

      await loader.load()

      expect(loader.localLoader).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('loaded', expect.objectContaining({
        detail: expect.objectContaining({
          url: '',
          content: '<p>Static content</p>',
        }),
      }))
    })

    it('does nothing when content is empty', async () => {
      global.fetch = vi.fn(async () => ({
        text: () => Promise.resolve(''),
      }))
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })

      await loader.load()

      expect(mockController.dispatch).toHaveBeenCalledWith('load', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('loading', expect.any(Object))
      expect(mockController.dispatch).not.toHaveBeenCalledWith('loaded', expect.any(Object))
    })

    it('reloads when reload is "always"', async () => {
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
        reload: 'always',
      })
      loader.loadedAt = Date.now()

      await loader.load()

      expect(global.fetch).toHaveBeenCalledWith('/api/content')
    })

    it('awaits async onLoad callback', async () => {
      const onLoad = vi.fn(async () => {
        await new Promise((resolve) => setTimeout(resolve, 10))
        return true
      })
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
      })
      loader.onLoad = onLoad

      await loader.load()

      expect(onLoad).toHaveBeenCalled()
      expect(global.fetch).toHaveBeenCalled()
    })

    it('awaits async onLoaded callback', async () => {
      const onLoaded = vi.fn(async () => {
        await new Promise((resolve) => setTimeout(resolve, 10))
      })
      mockController.loaded = onLoaded
      const loader = new ContentLoader(mockController, {
        url: '/api/content',
        onLoaded: 'loaded',
      })

      await loader.load()

      expect(onLoaded).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('loaded', expect.any(Object))
    })
  })

  describe('enhance', () => {
    it('adds load method to controller', () => {
      const loader = new ContentLoader(mockController)

      expect(mockController.load).toBeDefined()
      expect(typeof mockController.load).toBe('function')
    })
  })

  describe('attachContentLoader', () => {
    it('creates and returns a ContentLoader instance', () => {
      const loader = attachContentLoader(mockController, {
        url: '/api/content',
      })

      expect(loader).toBeInstanceOf(ContentLoader)
      expect(loader.url).toBe('/api/content')
    })
  })
})
