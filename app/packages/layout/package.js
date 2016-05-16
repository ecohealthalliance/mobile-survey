Package.describe({
  name: 'gq:layout',
  version: '0.0.1',
  summary: 'Good Question Survey base layout',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'ecmascript',
    'coffeescript',
    'underscore',
    'blaze-html-templates',
    'templating',
    'mquandalle:jade',
    'stylus',
  ], 'client');

  api.addFiles([
    'styles/main.styl',
    'views/header.jade',
    'views/layout.jade',
    'controllers/header.coffee',
  ], 'client');

  api.addAssets([
    'images/favicon.png',
    'images/logo.svg'
  ], 'client');
});
