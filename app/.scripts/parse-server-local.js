#!/usr/bin/env node

// Note: command to start parse-dashboard server is:
//       parse-dashboard --appId Acceptance --masterKey test --serverURL "http://localhost:31337/parse" --appName Acceptance\ Tests

var express = require('express');
var ParseServer = require('parse-server').ParseServer;

var port = 31337;

console.log('Initiating local parse server instance on port ' + port)

var app = express();
var api = new ParseServer({
  databaseURI: 'mongodb://localhost:13001/meteor',
  appId: 'Acceptance',
  masterKey: 'test',
  serverURL: 'http://localhost:' + port + '/parse'
});

// Serve the Parse API at /parse URL prefix
app.use('/parse', api);

// CORS
app.use(function(mountPath, res, next) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  return next();
});

app.listen(port, function() {
  console.log('parse-server-example running on port ' + port + '.');
});
