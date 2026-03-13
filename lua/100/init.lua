--TODO: search "lua-plugin-doc" for reading plugin usage in nvim itsself 
--TODO: enable project analisis with a search function
--TODO: add quickfix list/search to preview finished implementing blocks
--TODO: keep track of running requests and enable cancelation or reedit
--TODO: reference skills
--TODO: expand context

local function setup(user_configurations)
	print('setup called')
end

local function create_window_visual(callback)
	return require('100.window').create_window_visual(callback)
end


return {
	setup = setup,
	create_window_visual = create_window_visual,
}
