'use strict'

console.log 'start'

app = require './app.coffee'
Vue = require 'vue'
#Vue.config.debug = true
new Vue app
