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

  onLoad = async ({ url }) => !!url;

  onLoading = async ({ url }) => {
    return url ? await this.remoteLoader(url) : await this.loader();
  };

  loader = async () => '';

  remoteLoader = async (url) => (await fetch(url)).text();

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

export const attachContentLoader = (controller, options) => new ContentLoader(controller, options);
