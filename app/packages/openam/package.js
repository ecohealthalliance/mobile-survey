Package.describe({
  name: 'gq:openam',
  version: '0.1.0',
  summary: 'OpenAM ForgeRock authentication module'
});

Package.onUse(function (api) {

  api.versionsFrom('1.2.1');

  api.use([
    'coffeescript',
    'ecmascript'
  ]);

  api.use([
    'kadira:flow-router',
    'stylus',
    'templating',
    'mquandalle:jade'
  ], 'client');

  api.use([
    'http'
  ], 'server');

  api.addFiles([
    'styles/signin.styl',
    'views/login.jade',
    'views/signup.jade',
    'controllers/login.coffee',
    'controllers/signup.coffee',
    'routes.coffee'
  ], 'client');

  api.addFiles([
    'openam.coffee'
  ], 'server');

});
