local active_windows = {}

local function create_window_visual(callback)
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
    title = "100",
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

	-- Setup events
  local win_group = vim.api.nvim_create_augroup("100_window" .. win_buf,{ clear = true })
  vim.api.nvim_create_autocmd({"WinLeave", "BufWinLeave", "BufUnload"}, { group = win_group, buffer = win_buf, callback = function()
		vim.api.nvim_del_augroup_by_id(win_group)
		vim.api.nvim_win_close(win_id, true)
	end,})

  vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win_id, true)
  end, { buffer = win_buf, nowait = true })

	vim.api.nvim_create_autocmd("BufWriteCmd", {group = win_group,buffer = win_buf, callback = function()
		local context = {}
		context.prompt = table.concat(vim.api.nvim_buf_get_lines(win_buf, 0, -1, false), "\n")
		context.skills = "parse prompt for skills"
		context.tools = "parse prompt for tools"
		context.selection = origSelection
		context.buffer = 1

		vim.api.nvim_win_close(win_id, true)

		-- Run throbber with with callback responsible for generating text to replace visual selection
		require('throbber').create_throbber(origBuffer, origSelectionMeta.rowstart, origSelectionMeta.colstart, origSelectionMeta.rowend, origSelectionMeta.colend, function(resolve, reject)
			return callback(context, resolve, reject)
		end)
  end,})
end

return {
	create_window_visual = create_window_visual,
}
