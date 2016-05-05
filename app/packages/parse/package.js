Package.describe({
  name: 'goodquestion:parse',
  version: '0.1.0',
  summary: 'Integration with parse'
});

Package.onUse(function (api) {
  api.versionsFrom('1.2.1');

  Npm.depends({
    parse: '1.8.3'
  });

  api.use('ecmascript');
  api.use('coffeescript');

  api.addFiles('parse.coffee');

  api.export('Parse');
});
