Package.describe({
  name: 'gq:base-styles',
  version: '0.0.1',
  summary: 'Stylus variables, mixins and globals',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use('stylus');

  api.addFiles([
    'globals.styl',
    'mixins.styl',
    'variables.styl',
  ], 'client', {isImport: true});

});
