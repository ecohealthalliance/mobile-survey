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
    'views/participants_header.jade',
    'views/participant_list.jade',
    'views/participants.jade',
    'views/participants_edit.jade',
    'views/participant_results.jade',
    'controllers/participants.coffee',
    'controllers/participant_list.coffee',
    'controllers/participants_edit.coffee'
  ], 'client');
});
