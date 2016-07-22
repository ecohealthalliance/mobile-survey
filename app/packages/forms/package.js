Package.describe({
  name: 'gq:forms',
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
    'bevanhunt:leaflet',
    'aldeed:geocoder@0.3.8',
    'tsega:bootstrap3-datetimepicker@4.17.37_1',
    'ajduke:bootstrap-tokenfield@0.5.0',
    'fourq:typeahead@1.0.0'
  ], ['client', 'server']);

  api.addFiles([
    'server/methods.coffee',
  ], 'server');

  api.addFiles([
    'styles/forms.styl',
    'views/form_edit.jade',
    'views/forms.jade',
    'views/form_list.jade',
    'views/form_details.jade',
    'views/form_results.jade',
    'controllers/forms.coffee',
    'controllers/form_list.coffee',
    'controllers/form_edit.coffee',
    'controllers/form_details.coffee',
    'controllers/form_results.coffee',
  ], 'client');
});
