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
    'stylus'
  ], ['client']);

  api.addFiles([
    'styles/index.styl',
    'views/survey_results.jade',
    'views/form_results_detail.jade',
    'views/types/basic_results_info.jade',
    'views/types/datetime_results.jade',
    'views/types/number_results.jade',
    'views/types/scale_results.jade',
    'views/types/text_answer_results.jade',
    'controllers/survey_results.coffee',
    'controllers/types/basic_results_info.coffee',
    'controllers/types/datetime_results.coffee',
    'controllers/types/number_results.coffee',
    'controllers/types/scale_results.coffee',
    'controllers/types/text_answer_results.coffee',
    'controllers/form_results_detail.coffee'
  ], 'client');
});
