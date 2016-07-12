Package.describe({
  name: 'gq:base-styles',
  version: '0.0.1',
  summary: 'Stylus variables, mixins and globals',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use(['stylus'], 'client');

  api.addFiles([
    'variables.styl',
    'globals.styl',
    'utilities.styl',
    'validator.styl',
    'lists.styl',
    'buttons.styl',
    'index.styl'
  ], 'client', {isImport: true});

});
