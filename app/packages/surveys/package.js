Package.describe({
  name: 'gq:surveys',
  version: '0.0.1',
  summary: 'Good Question Surveys',
});

Package.onUse(function(api) {

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
    'views/survey.jade',
    'views/survey_users.jade',
    'controllers/survey_users.coffee',
    'views/survey_user_edit.jade',
    'controllers/survey_user_edit.coffee',
    'views/survey_details.jade',
    'views/create_survey_modal.jade',
    'views/delete_survey_modal.jade',
    'views/surveys.jade',
    'controllers/survey.coffee',
    'controllers/survey_details.coffee',
    'controllers/create_survey_modal.coffee',
    'controllers/delete_survey_modal.coffee',
    'controllers/surveys.coffee',
  ], 'client');

});
