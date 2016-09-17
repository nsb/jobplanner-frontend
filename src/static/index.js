'use strict';

require( '../../node_modules/material-design-lite/material.css' );

var Elm = require('../elm/Main.elm');
var mountNode = document.getElementById('main');
var app = Elm.Main.embed(mountNode);
