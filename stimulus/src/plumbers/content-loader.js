import Plumber from './plumber';
import { tryParseDate } from './plumber/support';

const defaultOptions = {
  content: null,
  url: '',
  reload: 'never',
  stale: 3600,
  onLoad: 'load',
  onLoading: 'loading',
  onLoaded: 'loaded',
};

export class ContentLoader extends Plumber {
  /**
   * Creates a new ContentLoader plumber instance for async content loading.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} [options] - Configuration options
   * @param {*} [options.content] - Initial content value
   * @param {string} [options.url=''] - URL to fetch content from
   * @param {string} [options.reload='never'] - Reload strategy ('never', 'always', or 'stale')
   * @param {number} [options.stale=3600] - Seconds before content becomes stale
   * @param {string} [options.onLoad='load'] - Callback name to check if loadable
   * @param {string} [options.onLoading='loading'] - Callback name to load content
   * @param {string} [options.onLoaded='loaded'] - Callback name after loading
   */
  constructor(controller, options = {}) {
    super(controller, options);

    const config = Object.assign({}, defaultOptions, options);
    const { content, url, reload, stale } = config;
    this.content = content;
    this.url = url;
    this.reload = typeof reload === 'string' ? reload : defaultOptions.reload;
    this.stale = typeof stale === 'number' ? stale : defaultOptions.stale;

    const { onLoad, onLoading, onLoaded } = config;
    this.onLoad = onLoad;
    this.onLoading = onLoading;
    this.onLoaded = onLoaded;

    this.enhance();
  }

  /**
   * Checks if content should be reloaded based on reload strategy.
   * @returns {boolean} True if content should be reloaded
   */
  get reloadable() {
    switch (this.reload) {
      case 'never':
        return false;
      case 'always':
        return true;
      default: {
        const loadedAt = tryParseDate(this.loadedAt);
        return loadedAt && new Date() - loadedAt > this.state * 1000;
      }
    }
  }

  /**
   * Checks if content should be loaded based on URL presence.
   * Override this method to provide custom loading conditions.
   * @param {Object} params - Load parameters
   * @param {string} params.url - URL to load from
   * @returns {Promise<boolean>} True if content should be loaded
   */
  onLoad = async ({ url }) => !!url;

  /**
   * Loads content from remote or local source.
   * Override this method to provide custom loading logic.
   * @param {Object} params - Load parameters
   * @param {string} params.url - URL to load from
   * @returns {Promise<string>} Loaded content
   */
  onLoading = async ({ url }) => {
    return url ? await this.remoteLoader(url) : await this.loader();
  };

  /**
   * Provides local/static content when no URL is available.
   * Override this method to provide static content.
   * @returns {Promise<string>} Local content
   */
  loader = async () => '';

  /**
   * Fetches content from a remote URL.
   * Override this method to customize remote loading.
   * @param {string} url - URL to fetch from
   * @returns {Promise<string>} Fetched content
   */
  remoteLoader = async (url) => (await fetch(url)).text();

  /**
   * Loads content from remote or local source with lifecycle events.
   * Checks if loadable via onLoad, fetches content via onLoading,
   * and notifies via onLoaded callback.
   * @returns {Promise<void>}
   */
  load = async () => {
    if (this.loadedAt && !this.reloadable) return;

    this.dispatch('load', { detail: { url: this.url } });
    const loadable = await this.awaitCallback(this.onLoad, { url: this.url });
    if (!loadable) return;

    this.dispatch('loading', { detail: { url: this.url } });
    const content = await this.awaitCallback(this.onLoading, { url: this.url });
    if (!content) return;

    await this.awaitCallback('onLoaded', { url: this.url, content: content });
    this.loadedAt = new Date().getTime();
    this.dispatch('loaded', { detail: { url: this.url, content: content } });
  };

  enhance() {
    const context = this;
    Object.assign(this.controller, {
      load: context.load.bind(context),
    });
  }
}

/**
 * Factory function to create and attach a ContentLoader plumber to a controller.
 * @param {Object} controller - Stimulus controller instance
 * @param {Object} [options] - Configuration options
 * @returns {ContentLoader} ContentLoader plumber instance
 */
export const attachContentLoader = (controller, options) => new ContentLoader(controller, options);
