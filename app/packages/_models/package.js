Package.describe({
  name: 'gq:models',
  version: '0.0.1',
  summary: 'Models for Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'coffeescript',
    'ecmascript',
    'gq:parse'
  ], 'client');

  api.mainModule('models.coffee', 'client');

});
