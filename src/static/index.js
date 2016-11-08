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

app.ports.rruleToText.subscribe(function(){
  var rule = new RRule({
    freq: RRule.WEEKLY,
    count: 23
  })
  var msg = rule.toText()
  app.ports.rruleText.send(msg);
});
