Vue = require 'vue'

_ = Vue.util
module.exports =
	el: '#app'
	template: require('./app.jade')()
	replace: true
	data:
		areas: [
			{x: 0, y: 0, w: 200, h: 100, component: 'tree'}
			{x: 200, y: 0, w: 100, h: 100}
			{x: 0, y: 100, w: 100, h: 150}
			{x: 100, y: 100, w: 100, h: 150}
		]
		handlers: [
			{type: 'vertical', left: [0], right: [1]}
			{type: 'vertical', left: [2], right: [3]}
			{type: 'horizontal', top: [0,1], bottom: [2,3]}
		]
	components:
		handler: require './handler.coffee'
	methods:
		split: (id, type)->
			area = @areas[id]
			if type == 'horizontal'
				h2 = area.h/2
				newArea =
					x: area.x
					y: area.y + h2
					w: area.w
					h: h2
				newId = @areas.push(newArea) - 1
				area.h = h2
				console.log 'split', id, type, area, newArea

				for bar in @handlers
					if bar.type == 'horizontal'
						iTop = bar.top.indexOf id
						if iTop != -1
							bar.top.splice iTop, 1, newId
					if bar.type == 'vertical'
						if bar.left.indexOf(id) != -1
							bar.left.push newId
						if bar.right.indexOf(id) != -1
							bar.right.push newId

				@handlers.push
					type: 'horizontal'
					top: [id]
					bottom: [newId]
	attached: ->
		@move = (event) =>
			@$broadcast 'move', event.clientX, event.clientY
			#@$broadcast 'recalc'

		@stop = (event) =>
			@$broadcast 'stop'
			Vue.nextTick =>
				@$broadcast 'recalc'

		@resize = (event) =>
			Vue.nextTick =>
				@$broadcast 'recalc'

		_.on document.body, 'mousemove', @move
		_.on document.body, 'mousedown', @down
		_.on document.body, 'mouseup', @stop
		_.on window, 'resize', @resize
		@$broadcast 'recalc'

