'use strict';

require( 'material-design-lite/material.css' );
require( 'dialog-polyfill/dialog-polyfill.js' );

var RRule = require('rrulelib').RRule
var RRuleSet = require('rrulelib').RRuleSet
var rrulestr = require('rrulelib').rrulestr
var nlp = require('nlp');


var runtime = require( 'serviceworker-webpack-plugin/lib/runtime.js' );

if ('serviceWorker' in navigator) {
  var registration = runtime.register();
}

var Elm = require('../elm/Main.elm');
var apiKey = localStorage.getItem('apiKey');
var app;

app = Elm.Main.fullscreen({apiKey: apiKey});

app.ports.storeApiKey.subscribe(function(data){
  localStorage.setItem('apiKey', data);
});

app.ports.rruleToText.subscribe(function(rrule){
  var rules = rrulestr(rrule, {forceset: true});
  console.log(rules.all());
  // rules.all().map(function(rule) { console.log(rule.toText())})
  var msg = "hejsa"
  app.ports.rruleText.send(msg);
});
