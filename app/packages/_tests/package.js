Package.describe({
  name: 'gq:fixtures',
  version: '0.1.0',
  summary: 'Additional tools to aid acceptance and integration/unit testing'
});

Package.onUse(function (api) {
  api.use([
    'ecmascript',
    'coffeescript',
    'xolvio:cleaner',
  ], 'client');

  api.addFiles([
    'fixtures.coffee',
    'imports/data.coffee'
  ], 'client');
});
