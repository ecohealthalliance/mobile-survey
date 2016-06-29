Package.describe({
  name: 'gq:participants',
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
  ], ['client']);

  api.addFiles([
    'views/participants.jade',
    'views/participants_edit.jade',
    'controllers/participants.coffee',
    'controllers/participants_edit.coffee'
  ], 'client');
});
