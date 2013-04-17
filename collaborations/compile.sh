#!/usr/bin/env bash

coffee -o full_js/ -c coffee/collaboration_map.coffee

cat full_js/jquery.simplemodal.js full_js/libs/d3.v2.js full_js/plugins.js full_js/script.js  full_js/collaboration_map.js | uglifyjs -o js/vis.min.js
