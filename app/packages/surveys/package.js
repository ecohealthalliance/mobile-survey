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
    'styles/details.import.styl',
    'styles/main.import.styl',
    'styles/index.styl',
    'views/survey.jade',
    'views/survey_details.jade',
    'views/survey_details_pending.jade',
    'views/survey_details_active.jade',
    'views/edit_survey_modal.jade',
    'views/delete_survey_modal.jade',
    'views/surveys.jade',
    'controllers/survey.coffee',
    'controllers/survey_details.coffee',
    'controllers/survey_details_pending.coffee',
    'controllers/survey_details_active.coffee',
    'controllers/edit_survey_modal.coffee',
    'controllers/delete_survey_modal.coffee',
    'controllers/surveys.coffee',
  ], 'client');

});
