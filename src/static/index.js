'use strict';

require( '../../node_modules/material-design-lite/material.css' );
require( '../../node_modules/dialog-polyfill/dialog-polyfill.js' );

var runtime = require( '../../node_modules/serviceworker-webpack-plugin/lib/runtime.js' );

if ('serviceWorker' in navigator) {
  var registration = runtime.register();
}

var Elm = require('../elm/Main.elm');
var mountNode = document.getElementById('main');
var app = Elm.Main.embed(mountNode);
