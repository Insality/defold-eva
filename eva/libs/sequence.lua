local M = {}


local function resume(co)
	local _, err = coroutine.resume(co)
	if err then print(err) end
end

function M.run_once(fn, ...)
	coroutine.wrap(fn)(...)
end

function M.run_loop(fn, ...)
	coroutine.wrap(function(...)
		while true do
			fn(...)
		end
	end)(...)
end

function M.delay(seconds)
	local co = coroutine.running()
	assert(co, "You must call this from inside a sequence")
	timer.delay(seconds, false, function()
		resume(co)
	end)
	coroutine.yield()
end

function M.gui_animate(node, property, to, easing, duration, delay, playback)
	local co = coroutine.running()
	assert(co, "You must call this from inside a sequence")
	gui.animate(node, property, to, easing, duration or 0, delay or 0, function()
		resume(co)
	end, playback)
	coroutine.yield()
end

function M.go_animate(url, property, playback, to, easing, duration, delay)
	local co = coroutine.running()
	assert(co, "You must call this from inside a sequence")
	go.animate(url, property, playback, to, easing, duration or 0, delay or 0, function()
		resume(co)
	end, playback)
	coroutine.yield()
end

function M.spine_play_anim(url, anim_id, playback, play_properties)
	local co = coroutine.running()
	assert(co, "You must call this from inside a sequence")
	spine.play_anim(url, anim_id, playback, play_properties, function(self, message_id, message, sender)
		resume(co)
	end)
	coroutine.yield()
end

function M.gui_play_flipbook(node, id)
	local co = coroutine.running()
	assert(co, "You must call this from inside a sequence")
	gui.play_flipbook(node, id, function()
		resume(co)
	end)
	coroutine.yield()
end

function M.sprite_play_flipbook(url, id)
	local co = coroutine.running()
	assert(co, "You must call this from inside a sequence")
	sprite.play_flipbook(url, id, function()
		resume(co)
	end)
	coroutine.yield()
end

function M.http_request(url, method, headers, post_data, options)
	local co = coroutine.running()
	assert(co, "You must call this from inside a sequence")
	http.request(url, method, function(self, id, response)
		resume(co, response)
	end,headers, post_data, options)
	return coroutine.yield()
end

function M.http_get(url, headers, options)
	return M.http_request(url, "GET", headers, nil, options)
end

function M.http_post(url, headers, post_data, options)
	return M.http_request(url, "POST", headers, post_data, options)
end


return M
