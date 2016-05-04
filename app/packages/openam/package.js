Package.describe({
  name: 'goodquestion:openam',
  version: '0.1.0',
  summary: 'OpenAM ForgeRock authentication module'
});

Package.onUse(function (api) {

  api.versionsFrom('1.2.1');

  api.use('coffeescript');

  api.use('kadira:flow-router', 'client');
  api.use('stylus', 'client');
  api.use('templating', 'client');
  api.use('mquandalle:jade', 'client');

  api.use('http', 'server');
  api.addFiles('stylesheets/signin.styl', 'client');

  api.addFiles('views/login.jade', 'client');
  api.addFiles('views/signup.jade', 'client');

  api.addFiles('login.coffee', 'client');
  api.addFiles('signup.coffee', 'client');

  api.addFiles('routes.coffee', 'client');

  api.addFiles('openam.coffee', 'server');
});
