'use strict'

_ = require('vue').util

module.exports =
	attached: ->
		_.on 'scroll', @el

