local active_windows = {}

local function create_window_search(opts, callback)
	-- Create window
  local win_id = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "editor",
    width = math.floor(vim.api.nvim_list_uis()[1].width * 2 / 3),
    height =  math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    col = math.floor(vim.api.nvim_list_uis()[1].width * 1 / 6),
    row = math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = " 100 Search ",
    title_pos = "center",
    zindex = 1,
  })

	local win_buf = vim.fn.bufnr(vim.api.nvim_win_get_buf(win_id))
	vim.api.nvim_buf_set_name(win_buf, "100")
	vim.bo[win_buf].filetype = "100"
	vim.bo[win_buf].buftype = "acwrite"
	vim.bo[win_buf].bufhidden = "wipe"
	vim.bo[win_buf].swapfile = false
	vim.wo[win_id].number = true
  vim.wo[win_id].wrap = true
	vim.cmd("startinsert")

	-- Setup highlighting
	local win_highlights = vim.api.nvim_create_namespace("100.window.hightlights")
	vim.api.nvim_create_autocmd({"InsertLeave", "TextChanged", "TextChangedI" }, { group = win_group, buffer = win_buf, callback = function()
    vim.api.nvim_buf_clear_namespace(win_buf, win_highlights, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(win_buf, 0, -1, false)

		vim.fn.foreach({'@test', '@function'}, function(key,keyword)
			vim.fn.foreach(lines, function(linenum,linestring)

				-- Highlight keyword at beginning of line
				if(string.sub(linestring, 1, #keyword + 1) == keyword .. " ") then
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, 0, { end_col = #keyword, hl_group = "Search" })
				end

				-- Highlight keyword at end of line
				if(string.sub(linestring, #linestring - #keyword, -1) == " " .. keyword) then
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, #linestring - #keyword, { end_col = #linestring, hl_group = "Search" })
				end

				-- Highlight keyword between spaces
				local startIndex,endIndex = string.find(linestring, " " .. keyword .. " ", 1, true)
				while(startIndex) do
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, startIndex, { end_col = endIndex-1, hl_group = "Search" })
					startIndex,endIndex = string.find(linestring, " " .. keyword .. " ", endIndex, true)
					end
			end)
		end)
	end,})

	-- Setup events
  local win_group = vim.api.nvim_create_augroup("100.window",{ clear = true })
  vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave", "BufUnload"}, { group = win_group, buffer = win_buf, callback = function()
		vim.api.nvim_del_augroup_by_id(win_group)
		vim.api.nvim_win_close(win_id, true)
	end,})

  vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

  vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

	vim.api.nvim_create_autocmd("BufWriteCmd", {group = win_group,buffer = win_buf, callback = function()
		local context = {
			prompt = table.concat(vim.api.nvim_buf_get_lines(win_buf, 0, -1, false), "\n"),
			skills = "parse prompt for skills",
			tools = "parse prompt for tools",
			buffer = 1
		}

		vim.api.nvim_win_close(win_id, true)

		-- Run user defined callback for searching project
		return callback(context, function(content)
			vim.schedule(function()
				local qfitems = vim.fn.map(vim.fn.split(content, '\n', false), function(key,value)
					local temp = vim.fn.split(value, '|', false)
					return {
						filename = temp[1],
						lnum = tonumber(temp[2]),
						col = tonumber(temp[3]),
						text = temp[5]
					}
				end)

				print('100.nvim: Performing search. This may take some time')

				vim.fn.setqflist({}, "r", { title = "100-Search", items = qfitems })
				vim.cmd("copen")
			end)
		end, reject)
  end,})
end

local function create_window_query(opts, callback)
	-- Create window
  local win_id = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "editor",
    width = math.floor(vim.api.nvim_list_uis()[1].width * 2 / 3),
    height =  math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    col = math.floor(vim.api.nvim_list_uis()[1].width * 1 / 6),
    row = math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = " 100 Query ",
    title_pos = "center",
    zindex = 1,
  })

	local win_buf = vim.fn.bufnr(vim.api.nvim_win_get_buf(win_id))
	vim.api.nvim_buf_set_name(win_buf, "100")
	vim.bo[win_buf].filetype = "markdown"
	vim.bo[win_buf].buftype = "acwrite"
	vim.bo[win_buf].bufhidden = "wipe"
	vim.bo[win_buf].buflisted = false
	vim.bo[win_buf].swapfile = false
	vim.wo[win_id].number = true
  vim.wo[win_id].wrap = true
	vim.cmd("startinsert")

	-- Setup keymaps
  vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

  vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

	-- Setup events
  local win_group = vim.api.nvim_create_augroup("100.window",{ clear = true })
	vim.api.nvim_create_autocmd({"BufModifiedSet"}, { group = win_group, buffer = win_buf, callback = function()
		vim.bo[win_buf].modified = false -- To enable :q and :w with acwrite
	end,})

  vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave", "BufUnload"}, { group = win_group, buffer = win_buf, callback = function()
		vim.api.nvim_del_augroup_by_id(win_group)
		vim.api.nvim_buf_delete(win_buf, { unload = true })
		vim.api.nvim_win_close(win_id, true)
	end,})

	vim.api.nvim_create_autocmd("BufWriteCmd", {group = win_group,buffer = win_buf, callback = function()
		local context = {
			prompt = table.concat(vim.api.nvim_buf_get_lines(win_buf, 0, -1, false), "\n"),
			skills = "parse prompt for skills",
			tools = "parse prompt for tools",
			buffer = 1
		}

		-- Display Processing...
		local win_processing = vim.api.nvim_create_namespace("100.window.hightlights")
		vim.api.nvim_win_set_height(win_id, 1)
		vim.api.nvim_buf_set_lines(win_buf, 0, -1, false, {'Processing...'})
		vim.api.nvim_buf_set_extmark( win_buf, win_processing, 0, 0, { end_row = 1, hl_group = "Comment" })

		-- Run user defined callback for searching project
		return callback(context, function(content)
			vim.schedule(function()
				if (vim.api.nvim_buf_is_valid(win_buf)) then
					vim.api.nvim_buf_clear_namespace(win_buf, win_processing, 0, -1)
					vim.api.nvim_win_set_height(win_id, math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3))

					local lines = vim.fn.split(content, '\n', true)
					vim.api.nvim_buf_set_lines(win_buf, 0, -1, false, lines)
					vim.api.nvim_win_set_cursor(win_id, {1, 1})
				end
			end)
		end, reject)
  end,})
end

local function create_window_insert(opts, callback)
	local origBuffer = vim.api.nvim_get_current_buf()
	local origCursor = vim.fn.getpos("v")

	-- Create window
  local win_id = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "editor",
    width = math.floor(vim.api.nvim_list_uis()[1].width * 2 / 3),
    height =  math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    col = math.floor(vim.api.nvim_list_uis()[1].width * 1 / 6),
    row = math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = " 100 Insert ",
    title_pos = "center",
    zindex = 1,
  })

	local win_buf = vim.fn.bufnr(vim.api.nvim_win_get_buf(win_id))
	vim.api.nvim_buf_set_name(win_buf, "100")
	vim.bo[win_buf].filetype = "100"
	vim.bo[win_buf].buftype = "acwrite"
	vim.bo[win_buf].bufhidden = "wipe"
	vim.bo[win_buf].swapfile = false
	vim.wo[win_id].number = true
  vim.wo[win_id].wrap = true
	vim.cmd("startinsert")

	-- Setup highlighting
	local win_highlights = vim.api.nvim_create_namespace("100.window.hightlights")
	vim.api.nvim_create_autocmd({"InsertLeave", "TextChanged", "TextChangedI" }, { group = win_group, buffer = win_buf, callback = function()
    vim.api.nvim_buf_clear_namespace(win_buf, win_highlights, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(win_buf, 0, -1, false)

		vim.fn.foreach({'@test', '@function'}, function(key,keyword)
			vim.fn.foreach(lines, function(linenum,linestring)

				-- Highlight keyword at beginning of line
				if(string.sub(linestring, 1, #keyword + 1) == keyword .. " ") then
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, 0, { end_col = #keyword, hl_group = "Search" })
				end

				-- Highlight keyword at end of line
				if(string.sub(linestring, #linestring - #keyword, -1) == " " .. keyword) then
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, #linestring - #keyword, { end_col = #linestring, hl_group = "Search" })
				end

				-- Highlight keyword between spaces
				local startIndex,endIndex = string.find(linestring, " " .. keyword .. " ", 1, true)
				while(startIndex) do
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, startIndex, { end_col = endIndex-1, hl_group = "Search" })
					startIndex,endIndex = string.find(linestring, " " .. keyword .. " ", endIndex, true)
					end
			end)
		end)
	end,})

	-- Setup events
  local win_group = vim.api.nvim_create_augroup("100.window",{ clear = true })
  vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave", "BufUnload"}, { group = win_group, buffer = win_buf, callback = function()
		vim.api.nvim_del_augroup_by_id(win_group)
		vim.api.nvim_win_close(win_id, true)
	end,})

  vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

  vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

	vim.api.nvim_create_autocmd("BufWriteCmd", {group = win_group,buffer = win_buf, callback = function()
		local context = {
			prompt = table.concat(vim.api.nvim_buf_get_lines(win_buf, 0, -1, false), "\n"),
			skills = "parse prompt for skills",
			tools = "parse prompt for tools",
			buffer = 1
		}

		local throbberOpts = {
			buf=origBuffer,
			rowstart=origCursor[2] + 1,
			colstart=0,
			rowend=origCursor[2] + 1,
			colend=0,
			description=context.prompt,
		}

		vim.api.nvim_win_close(win_id, true)

		-- Add line below for throbber to operate on
		vim.api.nvim_buf_set_lines(0, origCursor[2], origCursor[2], false, {''})
		vim.api.nvim_win_set_cursor(0, {origCursor[2] + 1, 0})

		-- Run throbber with a callback responsible for generating text to replace visual selection
		require('100.throbber').create_throbber(throbberOpts, function(resolve, reject)
			return callback(context, resolve, reject)
		end)
  end,})
end

local function create_window_replace(opts, callback)
	local origBuffer = vim.api.nvim_get_current_buf()
	local origSelection = require('100.buffer').getVisualContent()
	local origSelectionMeta = require('100.buffer').getVisualContentMeta()

	-- Create window
  local win_id = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
    relative = "editor",
    width = math.floor(vim.api.nvim_list_uis()[1].width * 2 / 3),
    height =  math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    col = math.floor(vim.api.nvim_list_uis()[1].width * 1 / 6),
    row = math.floor(vim.api.nvim_list_uis()[1].height * 1 / 3),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
    title = " 100 Replace ",
    title_pos = "center",
    zindex = 1,
  })

	local win_buf = vim.fn.bufnr(vim.api.nvim_win_get_buf(win_id))
	vim.api.nvim_buf_set_name(win_buf, "100")
	vim.bo[win_buf].filetype = "100"
	vim.bo[win_buf].buftype = "acwrite"
	vim.bo[win_buf].bufhidden = "wipe"
	vim.bo[win_buf].swapfile = false
	vim.wo[win_id].number = true
  vim.wo[win_id].wrap = true
	vim.cmd("startinsert")

	-- Setup highlighting
	local win_highlights = vim.api.nvim_create_namespace("100.window.hightlights")
	vim.api.nvim_create_autocmd({"InsertLeave", "TextChanged", "TextChangedI" }, { group = win_group, buffer = win_buf, callback = function()
    vim.api.nvim_buf_clear_namespace(win_buf, win_highlights, 0, -1)
    local lines = vim.api.nvim_buf_get_lines(win_buf, 0, -1, false)

		vim.fn.foreach({'@test', '@function'}, function(key,keyword)
			vim.fn.foreach(lines, function(linenum,linestring)

				-- Highlight keyword at beginning of line
				if(string.sub(linestring, 1, #keyword + 1) == keyword .. " ") then
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, 0, { end_col = #keyword, hl_group = "Search" })
				end

				-- Highlight keyword at end of line
				if(string.sub(linestring, #linestring - #keyword, -1) == " " .. keyword) then
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, #linestring - #keyword, { end_col = #linestring, hl_group = "Search" })
				end

				-- Highlight keyword between spaces
				local startIndex,endIndex = string.find(linestring, " " .. keyword .. " ", 1, true)
				while(startIndex) do
					vim.api.nvim_buf_set_extmark( win_buf, win_highlights, linenum, startIndex, { end_col = endIndex-1, hl_group = "Search" })
					startIndex,endIndex = string.find(linestring, " " .. keyword .. " ", endIndex, true)
					end
			end)
		end)
	end,})

	-- Setup events
  local win_group = vim.api.nvim_create_augroup("100.window",{ clear = true })
  vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave", "BufUnload"}, { group = win_group, buffer = win_buf, callback = function()
		vim.api.nvim_del_augroup_by_id(win_group)
		vim.api.nvim_win_close(win_id, true)
	end,})

  vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

  vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

	vim.api.nvim_create_autocmd("BufWriteCmd", {group = win_group,buffer = win_buf, callback = function()
		local context = {
			prompt = table.concat(vim.api.nvim_buf_get_lines(win_buf, 0, -1, false), "\n"),
			skills = "parse prompt for skills",
			tools = "parse prompt for tools",
			selection = origSelection,
			buffer = 1
		}

		local throbberOpts = {
			buf=origBuffer,
			rowstart=origSelectionMeta.rowstart,
			colstart=origSelectionMeta.colstart,
			rowend=origSelectionMeta.rowend,
			colend=origSelectionMeta.colend,
			description=context.prompt,
		}

		vim.api.nvim_win_close(win_id, true)

		-- Run throbber with a callback responsible for generating text to replace visual selection
		require('100.throbber').create_throbber(throbberOpts, function(resolve, reject)
			return callback(context, resolve, reject)
		end)
  end,})
end

return {
	create_window_search = create_window_search,
	create_window_query = create_window_query,
	create_window_insert = create_window_insert,
	create_window_replace = create_window_replace,
}
