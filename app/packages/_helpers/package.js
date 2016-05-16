Package.describe({
  name: 'gq:helpers',
  version: '0.0.1',
  summary: 'Helpers for Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'ecmascript',
    'coffeescript',
    'blaze-html-templates'
  ], 'client');

  api.addFiles('template_helpers.coffee', 'client');

  api.mainModule('helpers.coffee', 'client');

});
