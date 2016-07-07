Package.describe({
  name: 'gq:api',
  version: '0.0.1',
  summary: 'API for Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'modules',
    'coffeescript',
    'ecmascript',
    'gq:parse'
  ]);

  api.addFiles([
    'survey.coffee',
    'form.coffee',
    'question.coffee',
    'trigger.coffee',
    'index.coffee'
  ]);

  api.mainModule('index.coffee', 'client');
  api.mainModule('index.coffee', 'server');

});
