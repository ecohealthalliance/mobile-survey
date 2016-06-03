Package.describe({
  name: 'gq:api',
  version: '0.0.1',
  summary: 'API for Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'coffeescript',
    'ecmascript',
    'gq:parse'
  ], 'client');

  api.addFiles([
    'survey.coffee',
    'form.coffee',
    'question.coffee',
    'trigger.coffee'
  ], 'client');

  api.mainModule('api.coffee', 'client');

});
