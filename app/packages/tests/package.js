Package.describe({
  name: 'goodquestion:fixtures',
  version: '0.1.0',
  debugOnly: true,
  summary: 'Additional tools to aid acceptance and integration/unit testing'
});

Package.onUse(function (api) {
  api.versionsFrom('1.1.0.2');

  api.use('coffeescript');
  api.use('xolvio:cleaner');

  api.addFiles('fixtures.coffee');
});
