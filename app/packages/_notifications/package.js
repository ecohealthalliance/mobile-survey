Package.describe({
  name: 'gq:notifications',
  version: '0.0.1',
  summary: 'Remote Notifications for Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'coffeescript',
    'ecmascript',
    'mongo',
    'underscore',
    'gq:api',
    'gq:parse'
  ], 'server');


  api.addFiles([
  ], 'server');

  api.mainModule('index.coffee', 'server');
});
