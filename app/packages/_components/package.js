Package.describe({
  name: 'gq:components',
  version: '0.0.1',
  summary: 'Componentsfor Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'coffeescript',
    'mquandalle:jade',
    'stylus',
    'blaze-html-templates'
  ], 'client');

  api.addFiles([
    'loading/loading.styl',
    'loading/loading.jade',
    'loading/loading.coffee'
  ], 'client');

});