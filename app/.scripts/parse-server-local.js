#!/usr/bin/env node

'use strict'

var Settings = require('../settings-dev.json')

var port = 1337

var express = require('express')
var ParseServer = require('parse-server').ParseServer

console.log('Initiating local parse server instance on port ' + port)

var app = express();
var api = new ParseServer({
  databaseURI: 'mongodb://localhost:13001/meteor',
  appId: Settings.public.parseAppId,
  masterKey: Settings.private.parse.masterKey,
  serverURL: Settings.public.parseServerUrl
})

// Serve the Parse API at /parse URL prefix
app.use('/parse', api)

// CORS
app.use(function(mountPath, res, next) {
  res.setHeader("Access-Control-Allow-Origin", "*")
  return next()
})

app.listen(port, function() {
  console.log('Local parse server instance is running on port ' + port)
  console.log('\nThe command to start parse-dashboard:')
  console.log('parse-dashboard --appId ' + Settings.public.parseAppId + ' \\')
  console.log('                --masterKey "' + Settings.private.parse.masterKey + '" \\')
  console.log('                --serverURL "' + Settings.public.parseServerUrl + '" \\')
  console.log('                --appName TestApp')
})
