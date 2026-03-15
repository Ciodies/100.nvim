--TODO: search "lua-plugin-doc" for reading plugin usage in nvim itsself 
--TODO: enable project analisis with a search function
--TODO: add quickfix list/search to preview finished implementing blocks
--TODO: keep track of running requests and enable cancelation or reedit
--TODO: reference skills
--TODO: expand context

local function create_window_search(opts, callback)
	return require('100.window').create_window_search(opts, callback)
end

local function create_window_query(opts, callback)
	return require('100.window').create_window_query(opts, callback)
end

local function create_window_insert(opts, callback)
	return require('100.window').create_window_insert(opts, callback)
end

local function create_window_replace(opts, callback)
	return require('100.window').create_window_replace(opts, callback)
end

return {
	create_window_search = create_window_search,
	create_window_query = create_window_query,
	create_window_insert = create_window_insert,
	create_window_replace = create_window_replace,
}
