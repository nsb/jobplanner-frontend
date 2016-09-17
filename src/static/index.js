'use strict';

require( '../../node_modules/material-design-lite/material.css' );
require( '../../node_modules/dialog-polyfill/dialog-polyfill.js' );

var Elm = require('../elm/Main.elm');
var mountNode = document.getElementById('main');
var app = Elm.Main.embed(mountNode);
