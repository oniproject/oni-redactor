'use strict'

MIN = 50

module.exports =
	template: """
		<div class="handler {{type}}"
			v-on="mousedown: movable = true"
			style="left: {{x}}px; top: {{y}}px; width: {{width}}px; height: {{height}}px;"
			></div>
		"""
	replace: true
	data: -> {movable: false}

	events:
		stop: -> @movable = false
		move: (x, y)->
			return  unless @movable
			@x = x  if @type == 'vertical'
			@y = y  if @type == 'horizontal'
		recalc: ->
			@width = @width
			@height = @height
			if @type == 'horizontal'
				@x = @x
				@y = @y + @height
			if @type == 'vertical'
				@x = @x + @width
				@y = @y
			@width = @width
			@height = @height

	computed:
		x:
			get: ->
				if @type == 'horizontal'
					area = @$parent.areas[@top[0]]
					return area.x
				if @type == 'vertical'
					area = @$parent.areas[@left[0]]
					return area.w
			set: (val)->
				return  if @type == 'horizontal'
				areas = @$parent.areas
				start = @$parent.$el.clientWidth
				MAX = start - MIN - @width
				for i in @left
					area = areas[i]
					area.w = val - area.x - @width
					area.w = MIN if area.w < MIN
					area.w = MAX if area.w > MAX
				for i in @right
					area = areas[i]
					area.x = val
					if area.x > start - MIN
						area.x = start - MIN
					area.w = start - val
					area.w = MIN if area.w < MIN
				return
		y:
			get: ->
				if @type == 'horizontal'
					area = @$parent.areas[@top[0]]
					return area.h
				if @type == 'vertical'
					area = @$parent.areas[@left[0]]
					return area.y
			set: (val)->
				return  if @type == 'vertical'
				areas = @$parent.areas
				start = @$parent.$el.clientHeight
				MAX = start - MIN - @height
				for i in @top
					area = areas[i]
					area.h = val - area.y - @height
					area.h = MIN if area.h < MIN
					area.h = MAX if area.h > MAX
				for i in @bottom
					area = areas[i]
					area.y = val
					if area.y > start - MIN
						area.y = start - MIN
					area.h = start - val
					area.h = MIN if area.h < MIN
				return
		width: ->
			return 4  if @type == 'vertical'
			areas = @$parent.areas
			if @top.length == 1
				return areas[@top[0]].w
			w = @top
				.map (id)-> areas[id]
				.reduce (a, b)-> a.w+b.w
			#w = 30 if w < 30
			return w
		height: ->
			return 4  if @type == 'horizontal'
			areas = @$parent.areas
			if @left.length == 1
				return areas[@left[0]].h
			h = @left
				.map (id)-> areas[id]
				.reduce (a, b)-> a.h+b.h
			#h = 30 if h < 30
			return h
