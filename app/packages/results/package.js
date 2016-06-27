Package.describe({
  name: 'gq:results',
  version: '0.0.1',
  summary: 'Good Question Forms',
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
  ], ['client']);

  api.addFiles([
    'styles/index.styl',
    'views/survey_results.jade',
    'controllers/survey_results.coffee'
  ], 'client');
});
