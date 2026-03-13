-- Possible alternative can be found at: https://github.com/luvit/luvit/blob/master/deps/timer.lua
-- Possible alternative can be found at: https://dzx.fr/blog/async-lua-in-neovim/

local function setTimeout(delay, callback)
	return vim.defer_fn(callback, delay)
end

local function clearTimeout(timer)
	timer.close()
end

local function setInterval(interval, callback)
	local container = {}
	local recursiveCall
	recursiveCall = function()
		callback()
		container.timer = vim.defer_fn(recursiveCall, interval)
	end
	container.timer = vim.defer_fn(recursiveCall, interval)
	return container
end

local function clearInterval(timer)
	vim.uv.timer_stop(timer.timer)
end

local function setImmediate(callback)
	vim.defer_fn(callback, 0)
end

return {
  setTimeout = setTimeout,
	clearTimeout = clearTimeout,
  setInterval = setInterval,
  clearInterval = clearInterval,
  setImmediate = setImmediate,
}
