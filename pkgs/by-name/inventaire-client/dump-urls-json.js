import * as urls from './queries.js';

Object.keys(urls.default)
    .sort()
    .forEach(name => console.log(`${name}|${urls.default[name]}`));
