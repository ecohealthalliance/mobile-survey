Package.describe({
  name: 'gq:components',
  version: '0.0.1',
  summary: 'Componentsfor Good Question',
});

Package.onUse(function(api) {
  api.versionsFrom('1.3.2.2');

  api.use([
    'coffeescript',
    'mquandalle:jade',
    'stylus',
    'blaze-html-templates'
  ], 'client');

  api.addFiles([
    'list_flank/list_flank.styl',
    'list_flank/list_flank.jade',
    'list_flank/list_flank.coffee',

    'button_add/button_add.jade',
    'button_add/button_add.styl',
    'button_back/button_back.styl',
    'button_back/button_back.jade',

    'loading/loading.styl',
    'loading/loading.jade',
    'loading/loading.coffee'

  ], 'client');

});
