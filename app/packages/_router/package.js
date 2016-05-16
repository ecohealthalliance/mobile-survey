Package.describe({
  name: 'gq:router',
  version: '0.0.1',
  summary: 'Router for Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'coffeescript',
    'blaze-html-templates',
    'kadira:blaze-layout',
    'kadira:flow-router',
    'arillo:flow-router-helpers',
    'zimme:active-route'
  ]);

  api.addFiles('routes.coffee');

  api.export('BlazeLayout');
  api.export('FlowRouter');

});
