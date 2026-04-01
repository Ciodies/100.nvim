local active_throbbers = {}

local function create_throbber(opts, callback)
	local iteration = 1

	-- Setup marks
	local chars = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local namespace = vim.api.nvim_create_namespace('100')

	local colstart = math.min(#vim.api.nvim_buf_get_lines(opts.buf, opts.rowstart - 1, opts.rowstart, false)[1] - 1, opts.colstart - 1)
	local colend = math.min(#vim.api.nvim_buf_get_lines(opts.buf, opts.rowend - 1, opts.rowend, false)[1], opts.colend)

	local mark1 = vim.api.nvim_buf_set_extmark(opts.buf, namespace, opts.rowstart-1, colstart, {virt_lines_above=true,right_gravity=false,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing','Comment'}}, {{opts.description,'Comment'}}}})
	local mark2 =	vim.api.nvim_buf_set_extmark(opts.buf, namespace, opts.rowend  -1, colend, {virt_lines_above=false,right_gravity=false,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing','Comment'}}}})

	-- Setup and run throbber animation
	local updateInterval = require('100.timer').setInterval(150, function()
		iteration = iteration % #chars + 1

		local mark1data = vim.api.nvim_buf_get_extmark_by_id(opts.buf, namespace, mark1, {details=true})
		local mark2data = vim.api.nvim_buf_get_extmark_by_id(opts.buf, namespace, mark2, {details=true})

		vim.api.nvim_buf_set_extmark(opts.buf, namespace, mark1data[1], mark1data[2], {id=mark1,virt_lines_above=true,right_gravity=true,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing','Comment'}}, {{opts.description,'Comment'}}}})
		vim.api.nvim_buf_set_extmark(opts.buf, namespace, mark2data[1], mark2data[2], {id=mark2,virt_lines_above=false,right_gravity=false,virt_text={{''}},virt_lines={{{chars[iteration] .. ' Implementing','Comment'}}}})
	end)

	-- Run user defined callback immediatly with resolve and reject callbacks. if user defined callback calls the resolve function, the content of the trobber will be replaced
	callback(function(content)
			vim.schedule(function()
				require('100.timer').clearInterval(updateInterval)

				local mark1data = vim.api.nvim_buf_get_extmark_by_id(opts.buf, namespace, mark1, {details=true})
				local mark2data = vim.api.nvim_buf_get_extmark_by_id(opts.buf, namespace, mark2, {details=true})

				vim.api.nvim_buf_set_text(opts.buf, mark1data[1], mark1data[2], mark2data[1], mark2data[2], vim.fn.slice(vim.fn.split(content, '\n', true), 0, -1))

				vim.schedule(function ()
					vim.api.nvim_buf_del_extmark(opts.buf, namespace, mark1)
					vim.api.nvim_buf_del_extmark(opts.buf, namespace, mark2)
				end)
			end)
		end,
		function()
			vim.schedule(function()
				require('100.timer').clearInterval(updateInterval)

				vim.api.nvim_buf_del_extmark(opts.buf, namespace, mark1)
				vim.api.nvim_buf_del_extmark(opts.buf, namespace, mark2)
			end)
		end)
end

return {
	create_throbber = create_throbber
}
