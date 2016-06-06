Package.describe({
  name: 'gq:questions',
  version: '0.0.1',
  summary: 'Good Question Questions',
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
    'views/questions_add.jade',
    'views/question_details.jade',
    'views/question_details_edit.jade',
    'views/questions.jade',
    'controllers/questions_add.coffee',
    'controllers/question_details.coffee',
    'controllers/question_details_edit.coffee',
    'controllers/questions.coffee',
  ], 'client');

});
